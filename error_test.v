module dotenv

fn test_parse_end_before_variable_name() {
	load_text('=', true) or {
		if err is LoadError {
			assert err.msg() == 'unexpected "=" encountered when expecting a variable name on line 1, column 1'
			assert err.msg_full() == 'unexpected "=" encountered when expecting a variable name:
 1 | =
   | ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_in_variable_name() {
	load_text('test', true) or {
		if err is LoadError {
			assert err.msg() == 'unexpected end encountered when parsing a variable name on line 1, column 5'
			assert err.msg_full() == 'unexpected end encountered when parsing a variable name:
 1 | test
   |     ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_eoln_in_variable_name() {
	load_text('test
', true) or {
		if err is LoadError {
			assert err.msg() == 'unexpected line break encountered when parsing a variable name on line 1, column 5'
			assert err.msg_full() == 'unexpected line break encountered when parsing a variable name:
 1 | test
   |     ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_after_variable_name_1() {
	load_text('test ', true) or {
		if err is LoadError {
			assert err.msg() == 'unexpected end encountered after a variable name on line 1, column 6'
			assert err.msg_full() == 'unexpected end encountered after a variable name:
 1 | test 
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_end_after_variable_name_2() {
	load_text('test 
', true) or {
		if err is LoadError {
			assert err.msg() == 'unexpected line break encountered after a variable name on line 1, column 6'
			assert err.msg_full() == 'unexpected line break encountered after a variable name:
 1 | test 
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}

fn test_parse_unexpected_after_variable_name() {
	load_text('test *', true) or {
		if err is LoadError {
			assert err.msg() == 'unexpected "*" encountered when expecting "=" on line 1, column 6'
			assert err.msg_full() == 'unexpected "*" encountered when expecting "=":
 1 | test *
   |      ^'
		} else {
			assert false
		}
		return
	}
	assert false
}
