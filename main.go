package main

import (
	"fmt"
	"log"

	"github.com/tarm/serial"
)

func main() {

	fmt.Println("Go Pi!")

	c := &serial.Config{Name: "/dev/ttyAMA0", Baud: 115200}
	s, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal("Error opening serial port: " + err.Error())
	}

	dmxConsole := newConsole(s)
	err = dmxConsole.setSingle(100, 170)
	if err != nil {
		log.Fatal("Error sending command: " + err.Error())
	}

}
