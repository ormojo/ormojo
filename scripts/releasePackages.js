const { run, runArgs, capture } = require('./run')
const path = require('path')
const inquirer = require('inquirer')

function scoped(packages, cmd) {
  const scopes = packages.reduce((ps, p) => ps + `--scope ${p} `, '')
  return capture(`yarn run -s lerna ${scopes}${cmd}`)
}

function scopedExec(packages, cmd) {
  const args = ['yarn', 'run', '-s', 'lerna']
  packages.forEach((p) => { args.push('--scope'); args.push(p) })
  args.push('exec')
  args.push(cmd)
  return capture(args)
}

function scopedRun(packages, cmd) {
  const scopes = packages.reduce((ps, p) => ps + `--scope ${p} `, '')
  return run(`yarn run -s lerna ${scopes}${cmd}`)
}

// check that we're not running through `yarn`,
// which breaks because `npm whoami` returns nil
try {
  run(`npm whoami`, { useExec: true })
} catch (err) {
  console.warn('Cannot run as `yarn release`, must run as `npm run release`.')
  process.exit()
}

let packageList = process.argv.slice(2)
if (packageList[0] === "all") {
  const pkgsRaw = JSON.parse(capture("yarn run -s lerna ls --json").trim())
  packageList = []
  pkgsRaw.forEach((entry) => packageList.push(entry.name))
}
console.log("Releasing:", packageList)

const packages = packageList.map(packageName => {
  // Absolute path
  const abs = scopedExec([packageName], 'pwd').trim()
  // git status
  const gitStatus = scopedExec([packageName], 'git status --porcelain').trim()
  // git branch
  const gitBranch = scopedExec([packageName], 'git rev-parse --abbrev-ref HEAD').trim()
  return {
    name: packageName,
    path: path.relative(path.join(__dirname, '..'), abs),
    gitStatus: gitStatus,
    gitBranch: gitBranch
  }
})

const packageDirs = packages.map(package => package.path)

/////////////////// Health check
console.log("Preflight check:")
packages.forEach(package => {
  console.log("----------------------------------")
  console.log("Package: ", package.name)
  console.log("Path: ", package.path)
  console.log("Branch: ", package.gitBranch)
  console.log("----------------------------------")
  if (package.gitStatus.length > 0) {
    console.error(`Package ${package.name} has a dirty repository.`)
  }
  if (package.gitBranch === "HEAD") {
    console.error(`Package ${package.name} has a detached HEAD.`)
  }
});

inquirer.prompt([{type: 'confirm', default: false, name: 'go', message: 'Proceed?'}])
.then( answers => {
  if (!answers.go) throw new Error("User aborted release")

  //scoped(packageList, `run preversion`)

  //////////////////////// Version bump
  // allow user intervention on version numbers for each package
  scopedRun(packageList, `publish --skip-npm --skip-git`)

  // read version numbers and push git tags
  packages.forEach(package => {
    package.version = scopedExec([package.name], 'cat package.json | sed -nE "s/.*\\"version\\": ?\\"(.*)\\".*/\\1/p"').trim()
    //scoped([package.name], `exec -- git commit -am ${package.name}@${package.version}`)
    //scoped([package.name], `exec -- git tag ${package.name}@${package.version} -m ${package.name}@${package.version}`)
  })

  //////////////////////// Publish and push tags
  scoped(packageList, `exec -- npm publish`)
  //scoped(packageList, `exec -- git push && git push --tags`)

  //////////////////////// Push monorepo updates
  //run(`git add ${packageDirs.join(' ')}`)

  commitArgs = ['commit', '-m', 'Publish', '-m', 'Publish to NPM:']
  packages.forEach(info => {
    commitArgs.push('-m', `* ${info.name} v${info.version}`)
  })
  runArgs('git', commitArgs)

  run(`git push`)
} )
.catch(err => {
  console.error(err)
  process.exit(1)
})
