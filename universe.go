package main

import (
	"net/http"
	"strconv"

	"goji.io/pat"

	goji "goji.io"
)

type universe struct {
	console  *console
	channels [512]uint8
}

func newUniverse(console *console) *universe {
	return &universe{
		console: console,
	}
}

func (u *universe) mux() *goji.Mux {
	mux := goji.SubMux()
	mux.HandleFunc(pat.Get("/getall"), u.handlerGetAll)
	mux.HandleFunc(pat.Post("/setsingle/:channel"), u.handlerSetSingle)
	return mux
}

func (u *universe) handlerGetAll(w http.ResponseWriter, r *http.Request) {
	wsRespond(w, u.channels)
}
func (u *universe) handlerSetSingle(w http.ResponseWriter, r *http.Request) {
	strChannel := pat.Param(r, "channel")
	channel, errConv := strconv.Atoi(strChannel)
	if errConv != nil {
		wsRespondWithError(w, errConv)
		return
	}
	if channel < 1 || channel > 512 {
		wsRespondWithReason(w, "channel must be in the range 1..512")
		return
	}

	req, err := wsParseRequestBody(r)
	if err != nil {
		wsRespondWithError(w, err)
		return
	}

	rawValue, found := req["value"]
	if !found {
		wsRespondWithReason(w, "key 'value' not found in request")
		return
	}
	value, ok := rawValue.(float64)
	if !ok {
		wsRespondWithReason(w, "value was not a number")
		return
	}
	if value < 0 || value > 255 {
		wsRespondWithReason(w, "value must be in the range 0..255")
		return
	}

	u.channels[uint16(channel)-1] = uint8(value)
	errCon := u.console.setSingle(uint16(channel), uint8(value))
	if errCon != nil {
		wsRespondWithError(w, errCon)
	}

	wsRespond(w, nil)
}
