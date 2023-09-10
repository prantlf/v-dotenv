module dotenv

import os { exists, read_file, setenv }
import prantlf.debug { new_debug }
import prantlf.strutil { starts_with_within_nochk }

const d = new_debug('dotenv')

struct Parser {
	source    string
	overwrite bool
mut:
	line       int
	line_start int
}

fn (p &Parser) fail(offset int, msg string) LoadError {
	head_context, head_error := before_error(p.source, offset)
	tail_error, tail_context := after_error(p.source, offset)

	return LoadError{
		reason: msg
		head_context: head_context
		head_error: head_error
		tail_error: tail_error
		tail_context: tail_context
		offset: offset + 1
		line: p.line_start + 1
		column: offset - p.line_start + 1
	}
}

pub fn load_env(overwrite bool) !bool {
	return load_file('.env', overwrite)!
}

pub fn load_file(file string, overwrite bool) !bool {
	if !exists(file) {
		dotenv.d.log('dotenv file "%s" not found', file)
		return false
	}
	dotenv.d.log('load dotenv file "%s"', file)
	contents := read_file(file)!
	load_text(contents, overwrite)!
	return true
}

fn load_text(source string, overwrite bool) ! {
	if dotenv.d.is_enabled() {
		short_s := dotenv.d.shorten(source)
		dotenv.d.log_str('parse dotenv "${short_s}" (length ${source.len})')
		dotenv.d.stop_ticking()
		defer {
			dotenv.d.start_ticking()
		}
	}

	mut p := &Parser{
		source: source
		overwrite: overwrite
	}

	for i := p.after_bom(); true; {
		i = p.skip_whitespace(i)
		if i == p.source.len {
			break
		}
		i = p.load_variable(i)!
	}

	if dotenv.d.is_enabled() {
		dotenv.d.start_ticking()
		dotenv.d.log_str('dotenv finished')
	}
}

[direct_array_access]
fn (mut p Parser) load_variable(from int) !int {
	source := p.source
	mut name := ''
	mut name_start := from
	mut i := from
	for {
		match source[i] {
			`=` {
				if i == name_start {
					return p.fail(i, 'unexpected "=" encountered when expecting a variable name')
				}
				name = source[name_start..i]
				break
			}
			` `, `\t` {
				next := p.skip_space(i + 1)
				if next == source.len {
					if from != name_start {
						return next
					}
					return p.fail(next, 'unexpected end encountered after a variable name')
				}
				c := source[next]
				if c == `\r` || c == `\n` {
					if from != name_start {
						return next
					}
					return p.fail(next, 'unexpected line break encountered after a variable name')
				}
				if c == `=` {
					name = source[name_start..i]
					i = next
					break
				}
				if from != name_start {
					return p.skip_line(next + 1)
				}
				if unsafe { starts_with_within_nochk(source, 'export', from, source.len) } {
					name_start = next
					i = next
				} else {
					return p.fail(next, 'unexpected "${rune(c)}" encountered when expecting "="')
				}
			}
			`\r`, `\n` {
				if from != name_start {
					return i
				}
				return p.fail(i, 'unexpected line break encountered when parsing a variable name')
			}
			else {
				i++
				if i == source.len {
					return p.fail(i, 'unexpected end encountered when parsing a variable name')
				}
			}
		}
	}

	mut start := 0
	i = p.skip_space(i + 1)
	start = i
	mut last_space := 0
	for i < source.len {
		match source[i] {
			`\r`, `\n` {
				break
			}
			` `, `\t` {
				if last_space == 0 {
					last_space = i
				}
			}
			else {
				if last_space != 0 {
					last_space = 0
				}
			}
		}
		i++
	}
	mut end := if last_space > 0 {
		last_space
	} else {
		i
	}
	if start < end && source[start] == `"` {
		start++
	}
	if start < end && source[end - 1] == `"` {
		end--
	}
	val := source[start..end]

	setenv(name, val, p.overwrite)
	dotenv.d.log('set variable "%s" to "%s"', name, val)
	return i
}

[direct_array_access]
fn (mut p Parser) skip_line(from int) int {
	source := p.source
	mut i := from
	for i < source.len {
		c := source[i]
		i++
		if c == `\n` {
			p.line++
			p.line_start = i
			break
		}
	}
	return i
}

[direct_array_access]
fn (p &Parser) skip_space(from int) int {
	source := p.source
	mut i := from
	for i < source.len {
		match source[i] {
			` `, `\t` {
				i++
			}
			else {
				break
			}
		}
	}
	return i
}

[direct_array_access]
fn (mut p Parser) skip_whitespace(from int) int {
	source := p.source
	mut i := from
	for i < source.len {
		match source[i] {
			` `, `\t`, `\r` {
				i++
			}
			`\n` {
				i++
				p.line++
				p.line_start = i
			}
			`#` {
				i = p.skip_comment(i)
			}
			else {
				break
			}
		}
	}
	return i
}

[direct_array_access]
fn (mut p Parser) skip_comment(from int) int {
	source := p.source
	mut i := from + 1
	for i < source.len {
		c := source[i]
		i++
		if c == `\n` {
			p.line++
			p.line_start = i
			break
		}
	}
	return i
}

[direct_array_access]
fn (p &Parser) after_bom() int {
	if p.source.len >= 3 {
		unsafe {
			text := p.source.str
			if text[0] == 0xEF && text[1] == 0xBB && text[2] == 0xBF {
				return 3
			}
		}
	}
	return 0
}
