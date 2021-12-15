module events

import io { Buffer }
import objects { Player }
import collections
import packets
import utils { log }
import time

pub fn change_action(mut io Buffer, mut p Player) {
	p.status_typ = io.read_byte()
	p.status = io.read_string()
	p.map_md5 = io.read_string()
	p.mods = io.read_u32()
	p.mode = io.read_byte()
	p.map_id = io.read_i32()

	utils.enqueue_players(packets.user_stats(p.stats()))
}

pub fn send_public_message(mut io Buffer, mut p Player) {
	io.read_string() // sender
	msg := io.read_string()
	chan_name := io.read_string()
	io.read_i32() // sender id

	if msg == '' {
		return
	}

	mut c := collections.get_channel_by_name(chan_name) or {
		log("[yellow]warn:[/yellow] $p.uname tried to send a message in $chan_name, although the channel doesn't exist")
		return
	}

	c.send(msg, mut p)
}

pub fn logout(mut io Buffer, mut p Player) {
	io.read_i32()

	if time.now().unix_time() - p.login_time < 1 {
		return
	}

	p.quit()
}

pub fn request_status_update(mut r Buffer, mut p Player) {
	p.enqueue(packets.user_stats(p.stats()))
}

pub fn ping(mut r Buffer, mut p Player) {}

pub fn send_private_message(mut r Buffer, mut p Player) {
	r.read_string()
	msg := r.read_string()
	reciever_ := r.read_string()
	r.read_i32()

	mut reciever := collections.get_player_by_uname(reciever_) or {
		log('[yellow]warn:[/yellow] $p.uname tried to send a private message to $reciever_, although the player is not online')
		return
	}

	p.send_msg(msg, mut reciever)
}

pub fn join_channel(mut r Buffer, mut p Player) {
	name := r.read_string()

	mut c := collections.get_channel_by_name(name) or {
		log('[light red]bug:[/light red] channel `$name` not found.')
		return
	}

	p.join_channel(mut c)
}

pub fn leave_channel(mut r Buffer, mut p Player) {
	name := r.read_string()

	mut c := collections.get_channel_by_name(name) or {
		log('[light red]bug:[/light red] channel `$name` not found.')
		return
	}

	p.leave_channel(mut c, true)
}

pub fn user_stats_request(mut r Buffer, mut p Player) {
	players := r.read_i32l()

	for player in players {
		if player == p.id {
			continue
		}

		mut u := collections.get_player_by_id(player) or { continue }

		if u.token !in online_players {
			continue
		}

		u.enqueue(packets.user_stats(u.stats()))
	}
}
