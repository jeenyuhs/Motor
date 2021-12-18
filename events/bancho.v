module events

import web { Connection }
import time
import utils { log }
import collections
import io
import packets

#flag -I @VMODROOT/lib
#flag @VMODROOT/lib/libbcrypt/bcrypt.c
#flag @VMODROOT/lib/libbcrypt/crypt_blowfish/crypt_blowfish.c
#flag @VMODROOT/lib/libbcrypt/crypt_blowfish/crypt_gensalt.c
#flag @VMODROOT/lib/libbcrypt/crypt_blowfish/wrapper.c

#include "libbcrypt/bcrypt.h"

fn C.bcrypt_checkpw(&char, &char) int

// Find a proper and simple way to handle packets.
// This had a lot of problems, so I'm not going to
// bother working on it further on.

const (
	ignored_packets = [79, 4]
)

struct Bancho {}

['/'; 'GET']
fn (b &Bancho) handle(mut conn Connection) {
	conn.send("You're a fucking ugly bitch. I want to stab you to death, and then play around with your blood.".bytes(),
		200)
}

['/'; 'POST']
fn (b &Bancho) handle_post(mut conn Connection) {
	if conn.headers['User-Agent'] != 'osu!' {
		conn.send("You're a fucking ugly bitch. I want to stab you to death, and then play around with your blood.".bytes(),
			403)
		return
	}

	if 'osu-token' !in conn.headers {
		login(mut conn)
		return
	}

	token := conn.headers['osu-token']

	mut player := collections.get_player(token) or {
		mut tmp := packets.announce(msg: 'Server restarting...')
		tmp << packets.server_restart(ms: 0)
		conn.send(tmp, 200)
		return
	}

	mut buffer := io.new_buffer(conn.body)
	mut pid := 0

	for !buffer.is_empty() {
		pid = buffer.read_i16()
		buffer.pos++
		len := buffer.read_i32()

		match pid {
			0 {
				change_action(mut buffer, mut player)
			}
			1 {
				send_public_message(mut buffer, mut player)
			}
			2 {
				logout(mut buffer, mut player)
			}
			3 {
				request_status_update(mut buffer, mut player)
			}
			25 {
				send_private_message(mut buffer, mut player)
			}
			63 {
				join_channel(mut buffer, mut player)
			}
			73, 74 {
				friend(mut buffer, mut player)
			}
			78 {
				leave_channel(mut buffer, mut player)
			}
			85 {
				user_stats_request(mut buffer, mut player)
			}
			else {
				if pid !in events.ignored_packets {
					log('[yellow]warn:[/yellow] packet `$pid` is not implemented')
				}

				if len != 0 {
					buffer.pos += len
				}
			}
		}
	}

	conn.send(player.flush(), 200)
}

fn login(mut conn Connection) {
	conn.headers['cho-token'] = 'no'

	mut ret := packets.protocol()

	body := conn.body.bytestr().split('\n')

	uname := body[0]
	usafe := uname.to_lower().replace(' ', '_')

	mut p := collections.get_player(usafe) or {
		log(err.msg)
		ret << packets.login_reply(id: -1)
		conn.send(ret, 200)
		return
	}

	p.generate_token()

	for token in online_players {
		if token == p.token {
			ret << packets.login_reply(id: -1)
			ret << packets.announce(msg: "You're already logged in.")
			conn.send(ret, 200)
			return
		}
	}

	pwd := body[1]

	if p.passhash.bytestr() !in cached_bcrypt {
		if C.bcrypt_checkpw(&char(pwd.str), &char(p.passhash.bytestr().str)) != 0 {
			log('[light red]error:[/light red] invalid password (NOT CACHED)')
			ret << packets.login_reply(id: -1)
			conn.send(ret, 200)
			return
		}
		cached_bcrypt[p.passhash.bytestr()] = pwd
	} else {
		if cached_bcrypt[p.passhash.bytestr()] != pwd {
			log('[light red]error:[/light red] invalid password (CACHED)')
			ret << packets.login_reply(id: -1)
			conn.send(ret, 200)
			return
		}
	}

	if p.privileges.has_flag(.banned) {
		log("[light purple]$p.uname[/light purple] tried to login, but failed to due so, since they're banned.")
		ret << packets.login_reply(id: -3)
		conn.send(ret, 200)
		return
	}

	// if p.privileges.has(.pending) {
	// 	p.privileges.set(.verified)
	// 	p.privileges.toggle(.pending)
	// 	go p.update_privileges_sql()
	// }

	p.ip = conn.headers['X-Real-IP'] or { '127.0.0.1' }
	p.client_version = body[2].split('|')[0]

	p.login_time = time.now().unix_time()
	p.get_stats()
	p.get_friends()

	ret << packets.login_reply(id: p.id)
	ret << packets.user_stats(p.stats())
	ret << packets.user_presence(p.presence())
	ret << packets.friends_list(ids: p.friends)

	for mut c in channels {
		if c.public {
			ret << packets.chan_info(c.info())

			if c.auto_join {
				ret << packets.chan_auto_join(name: c.name)
				p.join_channel(mut *c)
			}
		}
	}

	utils.enqueue_players(packets.user_presence(p.presence()))
	utils.enqueue_players(packets.user_stats(p.stats()))

	for _, player in cached_players {
		if player.token !in online_players {
			continue
		}

		ret << packets.user_presence(player.presence())
		ret << packets.user_stats(player.stats())
	}

	ret << packets.chan_info_end()

	ret << packets.announce(msg: 'Hello, World!')

	cached_players[p.token] = p
	online_players << p.token

	conn.headers['cho-token'] = p.token
	log('[blue]$p.uname[/blue] logged in')
	conn.send(ret, 200)
}
