module main

import config
import mysql
import objects { Channel, Player }

__global (
	config         &config.Config
	db             mysql.Connection
	cached_players map[string]Player
	cached_bcrypt  map[string]string
	online_players []string
	channels       []Channel
)
