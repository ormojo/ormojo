var exp;

try {
	exp = require("./src/index");
} catch(e) {
	if(/\/src\//.test(e.message || '')) {
		exp = require("./js/index");
	} else {
		console.log(e);
	}
}

module.exports = exp;
