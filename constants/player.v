module constants

[flag]
pub enum Privileges {
	banned
	normal
	verified
	supporter
	bat
	moderator
	admin
	dev
}

[inline]
pub fn (mut p Privileges) set_flag(flag Privileges) {
	unsafe {
		*p = Privileges(int(*p) | (int(flag)))
	}
}

[inline]
pub fn (p &Privileges) has_flag(flag Privileges) bool {
	return (int(*p) & int(flag)) != 0
}
