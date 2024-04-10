package server

import (
	"context"
	"fmt"
	"net/http"
	"strings"

	"github.com/Nerzal/gocloak/v13"
	"github.com/golang-jwt/jwt/v5"
)

type claimsContextKeyType string

const claimsContextKey claimsContextKeyType = claimsContextKeyType("claims")

type Keycloak struct {
	gocloak      *gocloak.GoCloak // keycloak client
	clientId     string           // clientId specified in Keycloak
	clientSecret string           // client secret specified in Keycloak
	realm        string           // realm specified in Keycloak
}

func NewKeycloak() *Keycloak {
	return &Keycloak{
		gocloak:      gocloak.NewClient("https://keycloak.ferris-s.de"),
		realm:        "flutter-test",
		clientId:     "example-backend-client",
		clientSecret: "pG3PRLAvYisdnQmXRZ3e12eVDwtBrMiI",
	}
}

func (k *Keycloak) retrospectToken(token string) (*gocloak.IntroSpectTokenResult, error) {
	// call Keycloak API to verify the access token
	result, err := k.gocloak.RetrospectToken(context.Background(), token, k.clientId, k.clientSecret, k.realm)
	return result, err
}

// func (k *Keycloak) decodeAccessToken(token string) (*jwt.Token, *jwt.MapClaims, error) {
// 	jwt, claims, err := k.gocloak.DecodeAccessToken(context.Background(), token, k.realm)
// 	return jwt, claims, err
// }

func (k *Keycloak) decodeAccessTokenKeycloakClaims(token string) (*jwt.Token, *KeycloakClaims, error) {
	// claims := KeycloakClaims{}
	claims := &KeycloakClaims{}
	jwt, err := k.gocloak.DecodeAccessTokenCustomClaims(context.Background(), token, k.realm, claims)

	return jwt, claims, err
}

func (k *Keycloak) VerifyToken(next http.Handler) http.Handler {
	f := func(w http.ResponseWriter, r *http.Request) {

		// try to extract Authorization parameter from the HTTP header
		token := r.Header.Get("Authorization")

		if token == "" {
			http.Error(w, "Authorization header missing", http.StatusUnauthorized)
			return
		}

		// extract Bearer token
		token = strings.Replace(token, "Bearer ", "", 1)

		if token == "" {
			http.Error(w, "Bearer Token missing", http.StatusUnauthorized)
			return
		}

		// call Keycloak API to verify the access token
		result, err := k.retrospectToken(token)
		if err != nil {
			http.Error(w, fmt.Sprintf("Invalid or malformed token: %s", err.Error()), http.StatusUnauthorized)
			return
		}
		// check if the token isn't expired and valid
		if !*result.Active {
			http.Error(w, "Invalid or expired Token", http.StatusUnauthorized)
			return
		}

		// add claims to context, so future methods can easily check claims
		_, claims, err := k.decodeAccessTokenKeycloakClaims(token)
		if err != nil {
			http.Error(w, fmt.Sprintf("Invalid or malformed token: %s", err.Error()), http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), claimsContextKey, claims)
		next.ServeHTTP(w, r.WithContext(ctx))
	}

	return http.HandlerFunc(f)
}

func (k *Keycloak) VerifyRole(role string, next http.Handler) http.Handler {
	return nil
}
