module.exports = {
  "presets": [
    "@babel/react",
    [
      "@lightscript",
      {
        "env": {
          "targets": { "ie": 11 }
        }
      }
    ]
  ]
}
