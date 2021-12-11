module collections

import objects { Player }

pub fn get_player(usafe string) ?Player {
	if usafe !in cached_players {
		r := db.query("SELECT uname, id, privileges, passhash FROM players WHERE usafe = '$usafe'") or {
			return error('[light red]error:[/light red] $err.msg')
		}

		defer {
			unsafe { r.free() }
		}

		mapped := r.maps()

		if mapped.len <= 0 {
			return error('[light red]error:[/light red] Player was not found.')
		}

		return Player{
			uname: mapped[0]['uname']
			usafe: usafe
			id: mapped[0]['id'].int()
			privileges: mapped[0]['privileges'].int()
			passhash: mapped[0]['passhash'].bytes()
		}
	}

	return cached_players[usafe]
}

pub fn get_user_by_token(token string) ?Player {
	for _, player in cached_players {
		if player.token == token {
			return player
		}
	}

	return error('player with token `$token` not found')
}
