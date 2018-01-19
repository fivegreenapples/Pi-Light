package main

type setSingle struct {
	channel uint16
	val     uint8
}

func (c setSingle) serialise() []byte {
	return []byte{
		1,
		byte(c.channel & 0xff),
		byte((c.channel >> 8) & 0xff),
		c.val,
	}
}
