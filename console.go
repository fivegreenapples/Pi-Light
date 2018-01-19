package main

import (
	"fmt"
	"io"
)

type console struct {
	dest io.Writer
}

func newConsole(w io.Writer) *console {
	return &console{
		dest: w,
	}
}

func (c *console) setSingle(channel uint16, value uint8) error {
	if channel == 0 {
		return fmt.Errorf("channel zero should never be set")
	}
	if channel > 512 {
		return fmt.Errorf("DMX512 supports only 512 channels. channel %d is invalid", channel)
	}

	command := setSingle{
		channel: channel,
		val:     value,
	}

	return c.sendSerialisable(command)
}

// func (c *console) sendRaw(bytes []byte) error {
// 	_, err := c.dest.Write(bytes)
// 	return err
// }
func (c *console) sendSerialisable(bytes serialiser) error {
	_, err := c.dest.Write(bytes.serialise())
	return err
}
