module.exports = {
	'env': {
		'es2020': true,
		'node' : true
	},
	'extends': [
		'eslint:recommended',
	],
	'parser': 'babel-eslint',
	'parserOptions': {
		'sourceType': 'module',
		'ecmaVersion': 10
	},
	'rules': {
		'indent': [ 'error', 'tab', { 'SwitchCase': 1 , 'ignoredNodes': ['TemplateLiteral'] } ],
		'quotes': [ 'error', 'single' ],
		'semi': [ 'error', 'always' ],
		'no-console': [ 'off' ],
		'eqeqeq': [ 'error', 'always' ],
		'camelcase': [ 'error' ],
		'no-shadow': [ 'error' ],
		'brace-style': [ 'error', 'stroustrup', { 'allowSingleLine': true } ],
		'no-var': [ 'error' ],
		'no-fallthrough': [ 'error' ],
		'eol-last': ['error', 'always'],
		'no-prototype-builtins': 'off',
	},
	'globals': {
	}
};
