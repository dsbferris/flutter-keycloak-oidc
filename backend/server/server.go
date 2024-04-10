package server

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

type Server struct {
	keycloak *Keycloak
	mux      *chi.Mux
	port     int
}

func NewServer(port int) *Server {

	k := NewKeycloak()
	r := chi.NewRouter()
	s := &Server{mux: r, port: port, keycloak: k}
	s.addRoutes()
	return s
}

func (s *Server) addRoutes() {
	r := s.mux

	// A good base middleware stack
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	// DONT USE FOR DEBUGGING!
	// r.Use(middleware.Timeout(10 * time.Second))

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("API says: this is public"))
	})

	r.Group(func(r chi.Router) {
		r.Use(s.keycloak.VerifyToken)
		r.Get("/protected", func(w http.ResponseWriter, r *http.Request) {
			claims, ok := r.Context().Value(claimsContextKey).(*KeycloakClaims)
			if !ok {
				// impossible, since the middleware would fail before,
				// so it a 500
				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
				return
			}
			claimsBytes, _ := json.Marshal(claims)
			w.Write(append([]byte("API says: Hello User!\nYour access token has successfully been verified by the keycloak instance. "+
				"These are your claims:\n\n"), claimsBytes...))

		})
	})
}

func (s *Server) Start() error {
	log.Printf("Starting on port %d\n", s.port)
	addr := fmt.Sprintf(":%d", s.port)
	err := http.ListenAndServe(addr, s.mux)
	return err
}
