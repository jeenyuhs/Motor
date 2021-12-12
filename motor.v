module main

import utils { log }
import objects
import config as conf
import packets
import collections
import mysql
import events
import web
import net.unix
import os

fn main() {
	log('[green]starting up...[/green]')

	if !os.exists('config.conf') {
		os.mv('ext/config.conf', 'config.conf') ?
		log("[light red]  failure:[/light red] you didn't have a config.conf file, so there's one created for you now, change it and motor again.")
		return
	}

	config = conf.parse_config('config.conf') or {
		log('[light red]  failure:[/light red] $err.msg')
		return
	}

	log('[green]  finished:[/green] parsed config')

	db = mysql.Connection{
		username: config.get('mysql.username')
		password: config.get('mysql.password')
		dbname: config.get('mysql.database')
	}

	db.connect() or {
		log("[light red]  failure:[/light red] couldn't connect to database")
		return
	}

	defer {
		db.close()
	}

	db.select_db('motor') ?

	log('[green]  finished:[/green] connected to database')

	chans := db.query('SELECT * FROM channels') ?

	for c in chans.maps() {
		channels << objects.Channel{
			name: c['name']
			description: c['description']
			public: c['public'] == '1'
			is_staff: c['staff'] == '1'
			read_only: c['read_only'] == '1'
			auto_join: c['auto_join'] == '1'
		}
	}
	unsafe { chans.free() }

	log('[green]  finished:[/green] initialized channels.')

	mut bot := collections.get_player(config.get('server.bot_name')) or {
		log('[light red]  failure:[/light red] bot account not found in database')
		log('[light red]$err.msg[/light red')
		return
	}

	bot.generate_token()
	bot.is_bot = true

	cached_players[bot.usafe] = bot
	online_players << bot.token

	for mut token in online_players {
		mut u := cached_players[token]
		u.enqueue(packets.user_presence(bot.presence()))
		u.enqueue(packets.user_stats(bot.stats()))
	}

	mut listener := unix.listen_stream(config.get('server.address')) or {
		log('[light red]  failure:[/light red] could not listen on port, maybe the address is already in use? error code `$err.code`')
		return
	}

	defer {
		listener.close() ?
	}

	log('[light purple]Running[/light purple] Motor')

	for {
		mut conn := listener.accept() or {
			log('[light red]  failure:[/light red] could not accept connection')
			break
		}

		handle_conn(mut conn)
	}
}

fn handle_conn(mut conn unix.StreamConn) {
	defer {
		conn.close() or { panic(err) }
	}

	mut buf := []byte{len: 1024}

	pos := conn.read(mut buf) or {
		log('[light red]  failure: [/light red] could not read data from connection')
		return
	}

	mut connection := web.new_conn(buf[..pos], conn)

	domain := config.get('server.domain')

	// this doesn't work the way i want it to be.
	// gonna submit an issue and see if its a bug
	// or a feature.

	if connection.headers['Host'] in [
		'c.$domain',
		'ce.$domain',
		'c4.$domain',
		'c5.$domain',
		'c6.$domain',
	] {
		connection.handle<events.Bancho>()
		// } else if connection.headers["Host"] == "osu.$domain" {
		// 	connection.handle<events.Osu>()
	} else {
		connection.send('I simply am not there.'.bytes(), 200)
	}
}
