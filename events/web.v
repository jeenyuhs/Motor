module events

import web { Connection }
import crypto.md5

struct Osu {}

['/'; 'GET']
pub fn (_ &Osu) osu(mut conn Connection) {
	conn.send('Hello, world!'.bytes(), 200)
}

['/web/osu-osz2-getscores.php'; 'GET']
pub fn (_ &Osu) get_scores(mut conn Connection) {
	conn.send('0|false'.bytes(), 200)
}

['/users'; 'POST']
pub fn (_ &Osu) register_user(mut conn Connection) {
	username := conn.post_args['user[username]']
	email := conn.post_args['user[user_email]']
	pwd := conn.post_args['user[password]']
	println(md5.hexhash(pwd))
}
