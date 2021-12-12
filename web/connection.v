module web

import utils { log }
import net.unix

pub struct Handler {
	path    string
	handle  fn (mut Connection) []byte
	methods []string
}

pub struct Router {
mut:
	host     []string
	handlers map[string]Handler
}

pub fn router(hosts []string) Router {
	return Router{
		host: hosts
	}
}

pub fn (mut r Router) register(path string, handle fn (mut c Connection) []byte, methods []string) {
	r.handlers[path] = Handler{
		path: path
		handle: handle
		methods: methods
	}
}

pub struct Connection {
mut:
	data_  []byte
	socket unix.StreamConn
pub mut:
	method   string
	path     string
	http_ver string

	headers   map[string]string
	args      map[string]string
	post_args map[string]string
	body      []byte

	ctx Handler
}

pub fn new_conn(body []byte, socket unix.StreamConn) Connection {
	mut conn := Connection{
		data_: body
		socket: socket
	}

	tmp := conn.data_.bytestr().split('\r\n')[0].split(' ')

	conn.method = tmp[0]
	conn.path = tmp[1]
	conn.http_ver = tmp[2]

	conn.parse_headers()
	conn.parse_args()

	conn.body = conn.data_.bytestr().split('\r\n').last().bytes()

	return conn
}

fn (mut c Connection) parse_args() {
	if c.method == 'POST' {
		if c.headers['Content-Type'] == 'multipart/form-data' {
			boundary := c.headers['Content-Type'].split(';')[1].split('=')[1]

			for arg in c.data_.bytestr().split('--$boundary')[1..] {
				if arg == '--\r\n' {
					break
				}

				name := arg.split('Content-Disposition: form-data; name="')[1].split('"')[0].replace('\r\n',
					'')
				value := arg.split('\r\n\r\n')[1].replace('\r\n', '')

				c.post_args[name] = value
			}
		}
	} else {
		if '?' in c.path.split('') {
			args := c.path.split('?')[1].split('&')

			for arg in args {
				t := arg.split('=')

				if t.len != 2 {
					continue
				}

				c.args[t[0]] = t[1]
			}
		}
	}
}

fn (mut c Connection) parse_headers() {
	parse := c.data_.bytestr().split('\r\n')[1..]

	for line in parse {
		if line.len == 0 {
			break
		}

		split := line.split(': ')
		c.headers[split[0]] = split[1]
	}
}

pub fn (mut conn Connection) handle<T>() {
	path := conn.path.split('?')[0]

	tmp := &T{}
	$for method in T.methods {
		if method.attrs.len >= 2 {
			fun_path := method.attrs[0]
			fun_method := method.attrs[1]

			if fun_path == path && fun_method == conn.method {
				tmp.$method(mut conn)
				return
			}
		}
	}
	log('[yellow]warn:[/yellow] `$path` not found.')
}

fn status_msg(code int) string {
	msg := match code {
		100 { 'Continue' }
		101 { 'Switching Protocols' }
		200 { 'OK' }
		201 { 'Created' }
		202 { 'Accepted' }
		203 { 'Non-Authoritive Information' }
		204 { 'No Content' }
		205 { 'Reset Content' }
		206 { 'Partial Content' }
		300 { 'Multiple Choices' }
		301 { 'Moved Permanently' }
		400 { 'Bad Request' }
		401 { 'Unauthorized' }
		403 { 'Forbidden' }
		404 { 'Not Found' }
		405 { 'Method Not Allowed' }
		408 { 'Request Timeout' }
		500 { 'Internal Server Error' }
		501 { 'Not Implemented' }
		502 { 'Bad Gateway' }
		else { '-' }
	}
	return msg
}

pub fn (mut conn Connection) send(data []byte, code int) {
	mut buf := []byte{}

	buf << '$conn.http_ver $code ${status_msg(code)}\r\n'.bytes()

	conn.headers['Content-Length'] = '$data.len'

	for key, value in conn.headers {
		buf << '$key: $value\r\n'.bytes()
	}

	buf << '\r\n'.bytes()
	buf << data

	conn.socket.write(buf) or { println(err) }
}
