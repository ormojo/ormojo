module.exports = {
  "presets": [
    [
      "@lightscript",
      {
        "env": {
          "targets": { "node": 8 }
        },
        "additionalPlugins": [
          "@babel/proposal-logical-assignment-operators"
        ]
      }
    ]
  ]
}
