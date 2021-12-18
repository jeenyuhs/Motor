module objects

import packets
import utils { log }

[heap]
pub struct Channel {
pub:
	raw         string
	name        string
	description string

	public    bool
	is_temp   bool
	is_staff  bool
	read_only bool
	auto_join bool
pub mut:
	connected []string
}

pub fn (c &Channel) is_special() bool {
	return c.name == '#multiplayer' || c.name == '#spectator' || c.name == 'spectators'
}

pub fn (c &Channel) is_dm() bool {
	return !c.raw.starts_with('#')
}

pub fn (c &Channel) update_info() {
	utils.enqueue_players(packets.chan_info(c.info()))
}

pub fn (c &Channel) is_connected(p Player) bool {
	for token in c.connected {
		if token == p.token {
			return true
		}
	}
	return false
}

[params]
pub struct Ignored {
	tokens []string
}

pub fn (mut c Channel) enqueue(b []byte, i Ignored) {
	for token in c.connected {
		if token in i.tokens {
			continue
		}
		mut player := cached_players[token]
		player.enqueue(b)
	}
}

pub fn (mut c Channel) send(msg string, mut p Player) {
	if c.read_only || !p.privileges.has_flag(.verified) {
		return
	}

	c.enqueue(packets.message(
		sender: p.uname
		msg: msg
		channel: c.name
		id: p.id
	),
		tokens: [p.token]
	)

	log('[light purple]<$p.uname>[/light purple] $msg | [yellow]$c.name[/yellow]')
}

pub fn (c &Channel) info() packets.ChanInfo {
	return packets.ChanInfo{
		name: c.name
		description: c.description
		connected: c.connected.len
	}
}
