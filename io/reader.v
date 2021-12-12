module io

// this method is averagely faster than v's crypto.binary.

pub struct Buffer {
pub mut:
	data []byte
	pos  int
}

pub fn new_buffer(data []byte) Buffer {
	return Buffer{
		data: data
	}
}

pub fn (b &Buffer) is_empty() bool {
	return (b.pos >= b.data[b.pos..].len && b.data[b.pos..].len == 0) || b.data.len < 7
}

pub fn (mut b Buffer) read_any(size int) &byte {
	if b.pos + size > b.data.len {
		return &byte(0)
	}

	defer {
		b.pos += size
	}

	return &b.data[b.pos]
}

pub fn (mut b Buffer) read_byte() u8 {
	defer {
		b.pos++
	}
	return b.data[b.pos]
}

pub fn (mut b Buffer) read_i16() i16 {
	return unsafe { *(&i16(b.read_any(2))) }
}

pub fn (mut b Buffer) read_u16() u16 {
	return unsafe { *(&u16(b.read_any(2))) }
}

pub fn (mut b Buffer) read_i32() int {
	return unsafe { *(&int(b.read_any(4))) }
}

pub fn (mut b Buffer) read_u32() u32 {
	return unsafe { *(&u32(b.read_any(4))) }
}

pub fn (mut b Buffer) read_i64() i64 {
	return unsafe { *(&i64(b.read_any(8))) }
}

pub fn (mut b Buffer) read_u64() u64 {
	return unsafe { *(&u64(b.read_any(8))) }
}

pub fn (mut b Buffer) read_i32l() []int {
	len := b.read_i16()
	mut ret := []int{}

	for _ in 0 .. len {
		ret << b.read_i32()
	}

	return ret
}

pub fn (mut b Buffer) read_string() string {
	b.pos++

	mut shift := 0
	mut result := 0

	for {
		byt := b.data[b.pos]
		b.pos++

		result |= (byt & 0x7F) << shift

		if (byt & 0x80) == 0 {
			break
		}

		shift += 7
	}

	defer {
		b.pos += result
	}

	return b.data[b.pos..b.pos + result].bytestr()
}
