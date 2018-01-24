package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/tarm/serial"
	goji "goji.io"
	"goji.io/pat"
)

func main() {

	ui := flag.String("ui", "", "Specify the UI docroot")
	flag.Parse()

	if *ui == "" {
		fmt.Println("UI docroot has not been specified")
		os.Exit(1)
	}

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
	mux.Handle(pat.New("/ws/0/*"), universes[0].mux())
	mux.Handle(pat.New("/ws/1/*"), universes[1].mux())

	uiFS := http.FileServer(http.Dir(*ui))
	http.Handle("/ui/", http.StripPrefix("/ui", uiFS))
	http.Handle("/ws/", mux)

	log.Println("Starting pilight webservice")
	err = http.ListenAndServe(":8080", http.DefaultServeMux)
	if err != nil {
		log.Fatal(err)
	}

}
