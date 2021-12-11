module utils

import math

pub fn time_taken(time i64) f64 {
	t := f64(time) / f64(1_000_000)
	return int(t * math.pow(10, 2) + .5) / math.pow(10, 2)
}

pub fn replace_in_cache<T>(new_ T, old T) {
	// old should already be initialized.
	mut new := new_
	new.get_stats()
	new.get_friends()

	$for field in T.fields {
		if new.$(field.name).str() != old.$(field.name).str() {
			cached_players[new.usafe] = new
			log('[green]debug:[/green] cached player updated: $new.usafe on $field.name')
			return
		}
	}
}

pub fn attrs_to_map(attrs []string) map[string]string {
	mut attr := map[string]string{}

	for a in attrs {
		kv := a.split(': ')
		attr[kv[0]] = kv[1]
	}

	return attr
}

pub fn enqueue_players(b []byte) {
	for _, mut player in cached_players {
		player.enqueue(b)
	}
}
