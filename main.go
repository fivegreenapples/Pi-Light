package main

import (
	"fmt"
	"log"
	"time"

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

	for {
		curTime := time.Now()
		dmxConsole.setSingle(100, byte(curTime.Hour()))
		time.Sleep(2 * time.Second)
		dmxConsole.setSingle(100, byte(curTime.Minute()))
		time.Sleep(2 * time.Second)
		dmxConsole.setSingle(100, byte(0))
		time.Sleep(5 * time.Second)
	}

}
