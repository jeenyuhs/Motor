module config

import os

pub struct Config {
mut:
	path string
	raw  []string

	data map[string]map[string]string
}

pub fn parse_config(path string) ?&Config {
	mut conf := Config{}

	conf.raw = os.read_lines(path) or { return error('config: cannot read file.') }

	conf.parse() or { return err }

	return &conf
}

// lazy parser. maybe i'll make something better sometime.

pub fn (mut conf Config) parse() ? {
	mut section_name := ''

	for line in conf.raw {
		if line.starts_with('[') && line.ends_with(']') {
			section_name = line[1..line.len - 1]
			continue
		}

		if line.split_nth(': ', 0).len == 2 {
			data := line.split(': ')
			conf.data[section_name][data[0]] = data[1]
		}
	}
}

pub fn (conf &Config) get(key string) string {
	data := key.split('.')

	if data[0] !in conf.data {
		return ''
	}

	if data[1] !in conf.data[data[0]] {
		return ''
	}

	return conf.data[data[0]][data[1]]
}
