var exp;

try {
	exp = require("./js/index");
} catch(e) {
	if(/\/js\//.test(e.message || '')) {
		exp = require("./src/index");
	} else {
		console.log(e);
	}
}

module.exports = exp;
