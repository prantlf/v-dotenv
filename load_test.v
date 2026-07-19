module dotenv

import os { getenv_opt, setenv, unsetenv }

fn test_parse_empty() {
	load_text('', true)!
}

fn test_parse_variable() {
	unsetenv('answer')
	load_text('answer=42', true)!
	assert getenv_opt('answer')? == '42'
}

fn test_parse_variable_with_whitespace() {
	unsetenv('answer')
	load_text(' answer = 42 ', true)!
	assert getenv_opt('answer')? == '42'
}

fn test_parse_variable_with_quotes() {
	unsetenv('answer')
	load_text(' answer = " 42 " ', true)!
	assert getenv_opt('answer')? == ' 42 '
}

fn test_parse_variable_with_comments() {
	unsetenv('answer')
	load_text('#
answer = 42
#', true)!
	assert getenv_opt('answer')? == '42'
}

fn test_parse_two_properties() {
	unsetenv('answer')
	unsetenv('question')
	load_text('answer=42
question=unknown', true)!
	assert getenv_opt('answer')? == '42'
	assert getenv_opt('question')? == 'unknown'
}

fn test_parse_empty_val() {
	unsetenv('answer')
	load_text('answer=', true)!
	$if windows {
		if _ := getenv_opt('answer') {
			assert false
		}
	} $else {
		assert getenv_opt('answer')? == ''
	}
}

fn test_parse_whitespace_val() {
	unsetenv('answer')
	load_text('answer= ', true)!
	$if windows {
		if _ := getenv_opt('answer') {
			assert false
		}
	} $else {
		assert getenv_opt('answer')? == ''
	}
}

fn test_parse_no_overwrite() {
	setenv('answer', '42', true)
	load_text('answer=43', false)!
	assert getenv_opt('answer')? == '42'
}
