module.exports = {
  "presets": [
    '@babel/preset-react',
    [
      "@lightscript",
      {
        "stdlib": {
          "lodash": false
        },
        "env": {
          "targets": {
            "chrome": 77,
            "firefox": 68,
            "edge": 17
          }
        }
      }
    ]
  ]
}
