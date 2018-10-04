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
  // Prior version
  const priorVersion = scopedExec([packageName], 'cat package.json | sed -nE "s/.*\\"version\\": ?\\"(.*)\\".*/\\1/p"').trim()
  // // git status
  // const gitStatus = scopedExec([packageName], 'git status --porcelain').trim()
  // // git branch
  // const gitBranch = scopedExec([packageName], 'git rev-parse --abbrev-ref HEAD').trim()
  return {
    name: packageName,
    absolutePath: abs,
    priorVersion: priorVersion,
    path: path.relative(path.join(__dirname, '..'), abs)
  }
})

const packageDirs = packages.map(package => package.path)

/////////////////// Health check
console.log("Preflight check:")
packages.forEach(package => {
  console.log("----------------------------------")
  console.log("Package: ", package.name)
  console.log("Path: ", package.path)
  console.log("Current version: ", package.priorVersion)
  console.log("----------------------------------")
});

inquirer.prompt([{type: 'confirm', default: false, name: 'go', message: 'Proceed?'}])
.then( answers => {
  if (!answers.go) throw new Error("User aborted release")

  //scoped(packageList, `run preversion`)
  scoped(packageList, `run --parallel clean`)
  scoped(packageList, `run --parallel build`)

  //////////////////////// Version bump
  // allow user intervention on version numbers for each package
  run(`yarn run -s lerna version --git-tag-version --no-push`)

  // read version numbers and stage changes
  packages.forEach(package => {
    package.version = scopedExec([package.name], 'cat package.json | sed -nE "s/.*\\"version\\": ?\\"(.*)\\".*/\\1/p"').trim()
    //scoped([package.name], `exec -- git commit -am ${package.name}@${package.version}`)
    //scopedExec([package.name], `git add -u`)
    // scopedExec([package.name], `git tag ${package.name}@${package.version} -m ${package.name}@${package.version}`)
  })

  //////////////////////// Publish and push tags
  packages.forEach(package => {
    if(package.version !== package.priorVersion) {
      run(`npm publish`, { cwd: package.absolutePath })
    }
  })
  //scoped(packageList, `exec -- git push && git push --tags`)

  //////////////////////// Push monorepo updates
  //run(`git add ${packageDirs.join(' ')}`)

  commitArgs = ['commit', '-m', '[publish]', '-m', 'Publish to NPM:']
  packages.forEach(package => {
    if(package.version !== package.priorVersion) {
      commitArgs.push('-m', `* ${package.name} v${package.version}`)
    }
  })
  runArgs('git', commitArgs)

  // Tag releases
  // packages.forEach(package => {
  //   if(package.version !== package.priorVersion) {
  //     scopedExec([package.name], `git tag ${package.name}@${package.version} -m ${package.name}@${package.version}`)
  //   }
  // })

  run(`git push`)
  run(`git push --tags`)
} )
.catch(err => {
  console.error(err)
  process.exit(1)
})
