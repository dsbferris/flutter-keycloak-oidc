package main

import (
	"github.com/dsbferris/flutter-keycloak-oidc/server"
)

func main() {
	s := server.NewServer(8080)
	s.Start()
}
