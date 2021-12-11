module utils

const (
	esc    = '\x1b[38;5;'
	end    = '\x1b[0m'
	format = {
		'red':          ['${esc}1m', end]
		'light red':    ['${esc}203m', end]
		'green':        ['${esc}2m', end]
		'yellow':       ['${esc}3m', end]
		'blue':         ['${esc}4m', end]
		'light purple': ['${esc}141m', end]
	}
)

pub fn log(msg string) {
	mut m := msg.split('')
	mut pos := 0

	mut index := 0

	mut new := []string{}

	for pos + 1 < m.len {
		if m[pos] == '[' {
			pos++
			start := pos

			for pos + 1 < m.len && m[pos] != ']' {
				pos++
			}

			mut color := msg[start..pos]

			if color.starts_with('/') {
				index = 1
				color = color[1..]
			}

			if color !in utils.format {
				continue
			}

			rep := utils.format[color][index]
			new << rep

			continue
		}

		pos++

		if m[pos] != '[' {
			new << m[pos]
		}
	}

	println(new.join(''))
}
