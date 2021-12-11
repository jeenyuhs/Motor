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

pub fn lobby_join(mut r Buffer, mut p Player) {
	println('lobby join')
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

	p.leave_channel(mut c)
}
