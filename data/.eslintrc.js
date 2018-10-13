module.exports = {
  "parser": "@lightscript/eslint-plugin",
  "plugins": ["@lightscript/eslint-plugin"],
  "extends": [
    "eslint:recommended",
    "plugin:@lightscript/recommended"
  ],
  "parserOptions": {
    "sourceType": "module"
  },
  "env": {
    "node": true,
    "es6": true
  },
  "rules": {
    "no-unreachable": 0,
    "no-console": "error"
  }
}
