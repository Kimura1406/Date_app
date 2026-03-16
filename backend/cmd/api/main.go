package main

import (
	"log"

	"github.com/kimura/dating/backend/internal/app"
)

func main() {
	server, err := app.NewServer()
	if err != nil {
		log.Fatalf("failed to initialize server: %v", err)
	}
	defer func() {
		if err := server.Close(); err != nil {
			log.Printf("failed to close database: %v", err)
		}
	}()

	log.Printf("kimura backend listening on :%s", server.Config.Port)
	if err := server.Start(); err != nil {
		log.Fatalf("server stopped: %v", err)
	}
}
