module events

import web { Connection }

struct Osu {}

['/'; 'GET']
pub fn (_ &Osu) osu(mut conn Connection) {
	conn.send('Hello, world!'.bytes(), 200)
}
