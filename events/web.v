module events

import web { Connection }

struct Osu {}

['/'; 'GET']
pub fn (_ &Osu) osu(mut conn Connection) {
	conn.send('Hello, world!'.bytes(), 200)
}

['/web/osu-osz2-getscores.php'; 'GET']
pub fn (_ &Osu) get_scores(mut conn Connection) {
	conn.send('0|false'.bytes(), 200)
}

// I doubt I'll implement registration from client side,
// due to attacks and V's bcrypt generating being incorrect.

// ['/users'; 'POST']
// pub fn (_ &Osu) register_user(mut conn Connection) {
// 	mut error_resp := map[string][]string{}
// 	conn.headers['content-type'] = 'application/json'

// 	username := conn.post_args['user[username]']
// 	email := conn.post_args['user[user_email]']
// 	pwd := conn.post_args['user[password]']

// 	usafe := username.to_lower().replace(' ', '_')

// 	user_with_username := db.query("SELECT 1 FROM players WHERE usafe = '$usafe' LIMIT 1") or {
// 		return
// 	}
// 	if user_with_username.maps().len != 0 {
// 		error_resp['username'] = ['A player with that username already exists.']
// 	}
// 	user_with_username.free()

// 	user_with_email := db.query("SELECT 1 FROM players WHERE email = '$email' LIMIT 1") or {
// 		return
// 	}
// 	if user_with_email.maps().len != 0 {
// 		error_resp['user_email'] = ['A player with that email already exists.']
// 	}
// 	user_with_email.free()

// 	if error_resp.len > 0 {
// 		conn.send("{'form_error': {'error': $error_resp}}".bytes(), 200)
// 		return
// 	}

// 	println(conn.post_args)

// 	if conn.post_args['check'] == '0' {
// 		hash := bcrypt.generate_from_password(md5.hexhash(pwd).bytes(), 12) or {
// 			conn.send('no'.bytes(), 200)
// 			return
// 		}
// 		db.query("INSERT INTO players (uname, usafe, email, passhash, registered) VALUES ('$username', '$usafe', '$email', '$hash', NOW())") or {
// 			println(err)
// 			return
// 		}
// 	}

// 	conn.send('ok'.bytes(), 200)
// }
