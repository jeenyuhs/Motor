module objects

import packets
import utils

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
	connected []Player
}

pub fn (c &Channel) is_special() bool {
	return c.raw.starts_with('#match_') || c.raw.starts_with('#group_')
		|| c.raw.starts_with('#spec_')
}

pub fn (c &Channel) is_dm() bool {
	return !c.raw.starts_with('#')
}

pub fn (c &Channel) update_info() {
	utils.enqueue_players(packets.chan_info(c.info()))
}

pub fn (c &Channel) info() packets.ChanInfo {
	return packets.ChanInfo{
		name: c.name
		description: c.description
		connected: c.connected.len
	}
}
