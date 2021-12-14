module collections

import objects { Channel }

pub fn get_channel_by_name(name string) ?&Channel {
	for c in channels {
		if c.name == name {
			return c
		}
	}

	return error('channel `$name` not found')
}
