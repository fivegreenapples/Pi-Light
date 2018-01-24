package main

type dmxCommand interface {
	id() byte
	data() []byte
}

type setSingle struct {
	channel uint16
	val     uint8
}

func (c setSingle) id() byte {
	return 1
}

func (c setSingle) data() []byte {
	return []byte{
		byte(c.channel & 0xff),
		byte((c.channel >> 8) & 0xff),
		c.val,
	}
}
