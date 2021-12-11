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

// fn find_and_execute_packets<T>(mut io Buffer, mut player Player) ? {
// 	mut tmp := T{}

// 	$for method in T.methods {
// 		for {
// 			if io.data.len < io.pos || io.pos == io.data.len {
// 				println('okwqpdpqwokd')
// 				return
// 			}

// 			tmp.id = io.read_u16()
// 			io.pos++
// 			len := io.read_i32()

// 			if len != 0 {
// 				io.pos += len
// 			}

// 			attrs := utils.attrs_to_map(method.attrs)
// 			println('got ${attrs['id']}, expected $tmp.id')
// 		}
// 	}
// }

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

	mut player := collections.get_user_by_token(conn.headers['osu-token']) or {
		mut tmp := packets.announce(msg: 'Server restarting...')
		tmp << packets.server_restart(ms: 0)
		conn.send(tmp, 200)
		return
	}

	mut buffer := io.new_buffer(conn.body)

	for !buffer.is_empty() {
		pid := buffer.read_u16()
		buffer.pos++
		len := buffer.read_i32()

		match pid {
			0 {
				change_action(mut buffer, mut player)
			}
			1 {
				// send public message
			}
			2 {
				logout(mut buffer, mut player)
			}
			3 {
				request_status_update(mut buffer, mut player)
			}
			4 {
				ping(mut buffer, mut player)
			}
			30 {
				lobby_join(mut buffer, mut player)
			}
			63 {
				join_channel(mut buffer, mut player)
			}
			78 {
				leave_channel(mut buffer, mut player)
			}
			else {
				log('[yellow]warn:[/yellow] packet `$pid` is not implemented')
				buffer.pos += len
			}
		}
	}

	conn.send(player.flush(), 200)
}

fn login(mut conn Connection) {
	conn.headers['cho-token'] = 'no'

	mut ret := packets.protocol()
	mut sw := time.new_stopwatch()

	defer {
		sw.stop()
		log('[blue]info:[/blue] login took ${sw.elapsed().nanoseconds() / f64(1_000_000)}ms')
	}

	body := conn.body.bytestr().split('\n')

	uname := body[0]
	usafe := uname.to_lower().replace(' ', '_')

	mut p := collections.get_player(usafe) or {
		log(err.msg)
		ret << packets.login_reply(id: -1)
		conn.send(ret, 200)
		return
	}

	p.ip = conn.headers['X-Real-IP'] or { '127.0.0.1' }

	pwd := body[1]

	sw.start()
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

	p.client_version = body[2].split('|')[0]

	p.login_time = time.now().unix_time()
	p.get_stats()
	p.get_friends()
	p.generate_token()

	cached_players[usafe].token = p.token

	ret << packets.login_reply(id: p.id)
	ret << packets.user_stats(p.stats())
	ret << packets.friends_list(ids: p.friends)

	for mut c in channels {
		if c.auto_join {
			p.join_channel(mut c)
		}
	}

	ret << packets.chan_info_end()

	ret << packets.announce(msg: 'Hello, World!')

	cached_players[usafe] = p
	online_players << p

	conn.headers['cho-token'] = p.token
	conn.send(ret, 200)
}

// struct Osu {}

// ['/'; 'GET']
// pub fn (osu &Osu) index(mut conn Connection) {
// 	conn.send('Hello, world!'.bytes(), 200)
// }
