package main

type serialiser interface {
	serialise() []byte
}
