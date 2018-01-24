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

	http.Handle("/ui", http.FileServer(http.Dir("/home/pi/go/src/github.com/fivegreenapples/PiLight/ui")))
	http.Handle("/ws", mux)

	log.Println("Starting pilight webservice")
	err = http.ListenAndServe(":8080", http.DefaultServeMux)
	if err != nil {
		log.Fatal(err)
	}

}
