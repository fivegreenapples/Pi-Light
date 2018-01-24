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

	return c.sendCommand(command)
}

func (c *console) sendCommand(cmd dmxCommand) error {

	bytes := []byte{}
	bytes = append(bytes, cmd.id())
	data := cmd.data()
	bytes = append(bytes, byte(len(data)))
	bytes = append(bytes, data...)

	_, err := c.dest.Write(bytes)
	return err
}
