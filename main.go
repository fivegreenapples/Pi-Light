package main

import (
	"log"
	"net/http"

	"github.com/tarm/serial"
	goji "goji.io"
	"goji.io/pat"
)

func main() {
	c := &serial.Config{Name: "/dev/ttyAMA0", Baud: 115200}
	s, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal("Error opening serial port: " + err.Error())
	}
	dmxConsole := newConsole(s)

	universes := [2]*universe{
		newUniverse(dmxConsole),
		newUniverse(dmxConsole),
	}

	mux := goji.NewMux()
	mux.Handle(pat.Get("/ws/0/*"), universes[0].mux())
	mux.Handle(pat.Get("/ws/1/*"), universes[1].mux())

	log.Println("Starting pilight webservice")
	err = http.ListenAndServe("localhost:8080", mux)
	if err != nil {
		log.Fatal(err)
	}

}
