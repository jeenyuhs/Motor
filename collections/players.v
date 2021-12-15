module collections

import objects { Player }

pub fn get_player(token string) ?&Player {
	if token !in cached_players {
		if token.split('-').len == 3 {
			return error("[light red]error:[/light red] Player doesn't exist.")
		}

		r := db.query("SELECT uname, id, privileges, passhash FROM players WHERE usafe = '$token'") or {
			return error('[light red]error:[/light red] $err.msg')
		}

		defer {
			unsafe { r.free() }
		}

		mapped := r.maps()

		if mapped.len <= 0 {
			return error('[light red]error:[/light red] Player was not found.')
		}

		return &Player{
			uname: mapped[0]['uname']
			usafe: token
			id: mapped[0]['id'].int()
			privileges: mapped[0]['privileges'].int()
			passhash: mapped[0]['passhash'].bytes()
		}
	}

	return cached_players[token]
}

pub fn get_player_by_uname(uname string) ?&Player {
	for _, player in cached_players {
		if player.uname == uname {
			return player
		}
	}

	return error('player with username `$uname` not found')
}

pub fn get_player_by_id(id int) ?&Player {
	for _, player in cached_players {
		if player.id == id {
			return player
		}
	}

	return error('player with id `$id` not found')
}
