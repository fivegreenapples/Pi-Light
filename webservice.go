package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type wsRequest map[string]interface{}

type wsResponse struct {
	Status string      `json:"status"`
	Reason string      `json:"reason"`
	Data   interface{} `json:"data"`
}

func wsRespond(w http.ResponseWriter, data interface{}) {
	response := wsResponse{
		Status: "OK",
		Data:   data,
	}
	responseData, err := json.Marshal(response)
	if err != nil {
		wsRespondWithReason(w, err.Error())
		return
	}
	w.Header().Set("Content-type", "application/json")
	_, err = w.Write(responseData)
	if err != nil {
		log.Printf("failed writing response: %s", err)
		return
	}
}
func wsRespondWithError(w http.ResponseWriter, e error) {
	wsRespondWithReason(w, e.Error())
}
func wsRespondWithReason(w http.ResponseWriter, reason string) {
	response := wsResponse{
		Status: "ERROR",
		Reason: reason,
		Data:   nil,
	}
	responseData, err := json.Marshal(response)
	if err != nil {
		log.Printf("failed marshalling error response: %s", err)
		return
	}
	w.Header().Set("Content-type", "application/json")
	_, err = w.Write(responseData)
	if err != nil {
		log.Printf("failed writing response: %s", err)
		return
	}
}

func wsParseRequestBody(r *http.Request) (wsRequest, error) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return nil, err
	}
	var wsr wsRequest
	if err := json.Unmarshal(body, &wsr); err != nil {
		return nil, err
	}
	return wsr, nil
}
