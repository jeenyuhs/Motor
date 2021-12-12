module objects

import utils { log }
import rand
import packets

pub struct Player {
pub mut:
	uname      string
	usafe      string
	id         int
	privileges int
	passhash   []byte
	token      string

	ip             string
	country        u8
	timezone       i8
	lat            f32
	lon            f32
	client_version string

	mode       u8
	status     string
	status_typ int
	map_md5    string
	map_id     int
	mods       u32

	r_score i64
	acc     f32
	p_count int
	t_score i64
	level   f32
	rank    int
	pp      i16

	channels map[string]Channel
	game     string
	friends  []int

	last_update f64
	login_time  f64

	is_bot bool

	queue []byte
}

fn (p &Player) get_current_mode() ?string {
	if p.mode > 3 {
		return error('Unexpected error; this should never happen. (MODE: $p.mode)')
	}

	m := match p.mode {
		0 { 'std' }
		1 { 'taiko' }
		2 { 'catch' }
		3 { 'mania' }
		else { '' }
	}

	if m == '' {
		return error('Unknown mode: $p.mode')
	}

	return m
}

pub fn (mut p Player) generate_token() {
	p.token = rand.uuid_v4()
}

pub fn (mut p Player) quit() {
	for _, mut c in p.channels {
		p.leave_channel(mut c, false)
	}

	index := online_players.index(p.token)
	online_players.pop(index)

	utils.enqueue_players(packets.logout(id: p.id))
}

pub fn (p &Player) has_channel(c &Channel) bool {
	for name, _ in p.channels {
		if name == c.name {
			return true
		}
	}
	return false
}

pub fn (mut p Player) leave_channel(mut c Channel, kicked bool) {
	if !p.has_channel(c) {
		return
	}

	p.channels.delete(c.name)

	if p.token in c.connected {
		c.connected.pop(c.connected.index(p.token))
	}

	if kicked {
		p.enqueue(packets.chan_leave(name: c.name))
	}

	c.update_info()
	log('[light purple]$p.uname left channel [yellow]$c.name[/yellow][/light purple]')
}

pub fn (mut p Player) join_channel(mut c Channel) {
	if p.has_channel(c) {
		return
	}

	p.channels[c.name] = c
	c.connected << p.token

	p.enqueue(packets.chan_join(name: c.name))
	c.update_info()

	log('[light purple]$p.uname joined channel [yellow]$c.name[/yellow][/light purple]')
}

pub fn (mut p Player) get_friends() {
	r := db.query('SELECT friend_id FROM friends WHERE user_id = $p.id LIMIT 1') or { return }

	for id in r.rows() {
		p.friends << id.vals[0].int()
	}

	unsafe { r.free() }
}

pub fn (mut p Player) get_stats() {
	mode := p.get_current_mode() or {
		log('[light red]bug:[/light red] player.get_stats() called with invalid mode ($p.mode).')
		return
	}

	r := db.query('SELECT r_score_$mode AS r_score, t_score_$mode AS t_score,
				   acc_$mode AS acc, p_count_$mode AS p_count, level_$mode AS level, 
				   pp_$mode AS pp FROM stats WHERE id = $p.id LIMIT 1') or {
		return
	}
	result := r.maps()[0]
	unsafe { r.free() }

	p.r_score = result['r_score'].i64()
	p.t_score = result['t_score'].i64()
	p.acc = result['acc'].f32()
	p.p_count = result['p_count'].int()
	p.level = result['level'].i8()
	p.pp = result['pp'].i16()
}

pub fn (mut p Player) flush() []byte {
	defer {
		p.queue.clear()
	}
	return p.queue
}

pub fn (mut p Player) enqueue(b []byte) {
	p.queue << b
}

pub fn (p &Player) stats() packets.UserStats {
	return packets.UserStats{
		id: p.id
		status: p.status_typ
		status_text: p.status
		map_md5: p.map_md5
		cur_mods: p.mods
		play_mode: p.mode
		map_id: p.map_id
		r_score: p.r_score
		accuracy: p.acc / 100.0
		playcount: p.p_count
		t_score: p.t_score
		rank: p.rank
		pp: p.pp
	}
}

pub fn (p &Player) presence() packets.UserPresence {
	return packets.UserPresence{
		id: p.id
		username: p.uname
		timezone: p.timezone
		country: p.country
		lon: p.lon
		lat: p.lat
		rank: p.rank
	}
}
