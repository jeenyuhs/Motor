module events

import constants { Privileges }
import objects { Channel, Player }
import config { parse_config }
import packets
import utils

fn handle_command<T>(msg string, mut c Channel, mut p Player) {
	args := msg.split(' ')[1..] // remove command from args
	cmd := msg.split(' ')[0][1..]

	mut ctx := &T{}

	$for method in T.methods {
		attrs := utils.attrs_to_map(method.attrs)

		if 'command' in attrs && attrs['command'] == cmd {
			if 'privileges' in attrs {
				match attrs['privileges'] {
					'admin' { ctx.privileges = .admin }
					'dev' { ctx.privileges = .dev }
					'moderator' { ctx.privileges = .moderator }
					'bat' { ctx.privileges = .bat }
					'normal' { ctx.privileges = .normal }
					'verified' { ctx.privileges = .verified }
					'supporter' { ctx.privileges = .supporter }
					else { panic('Invalid privilege') }
				}
			}

			if !p.privileges.has_flag(ctx.privileges) {
				return
			}

			ctx.player = p
			ctx.channel = c

			ctx.command = attrs['command']
			ctx.args = args

			ctx.$method()
		}
	}
}

struct Command {
pub mut:
	command    string
	aliases    []string
	privileges Privileges = .verified
	// context
	args    []string
	player  &Player
	channel &Channel
}

[command: 'ping']
fn (mut ctx Command) pong() {
	ctx.channel.send('Heheha', mut bot)
}

[command: 'config']
[privileges: 'dev']
fn (mut ctx Command) reload_config() {
	ctx.channel.send('Reloading config...', mut bot)

	config = parse_config('config.conf') or {
		ctx.channel.send('Failed to reload config!', mut bot)
		return
	}

	ctx.channel.send('Config reloaded!', mut bot)
}

[privileges: 'admin']
[command: 'alert']
fn (mut ctx Command) alert() {
	if ctx.args.len < 1 {
		ctx.channel.send('Usage: alert <message>', mut bot)
		return
	}

	utils.enqueue_players(packets.announce(msg: ctx.args[0]))
	ctx.channel.send('Done.', mut bot)
}
