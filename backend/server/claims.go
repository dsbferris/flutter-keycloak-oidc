package server

import "github.com/golang-jwt/jwt/v5"

type KeycloakClaims struct {
	jwt.RegisteredClaims
	// Exp            int      `json:"exp,omitempty"`
	// Iat            int      `json:"iat,omitempty"`
	// Jti            string   `json:"jti,omitempty"`
	// Iss            string   `json:"iss,omitempty"`
	// Aud            string   `json:"aud,omitempty"`
	// Sub            string   `json:"sub,omitempty"`

	AuthTime     int    `json:"auth_time,omitempty"`
	TokenType    string `json:"typ,omitempty"`
	ClientID     string `json:"azp,omitempty"`
	Scope        string `json:"scope,omitempty"`
	Nonce        string `json:"nonce,omitempty"`
	SessionState string `json:"session_state,omitempty"`
	SessionID    string `json:"sid,omitempty"`
	// Authentication Context Class References
	// See acr_values_supported in https://openid.net/specs/openid-connect-discovery-1_0.html
	Acr               string   `json:"acr,omitempty"`
	AllowedOrigins    []string `json:"allowed-origins,omitempty"`
	FullName          string   `json:"name,omitempty"`
	PreferredUsername string   `json:"preferred_username,omitempty"`
	FirstName         string   `json:"given_name,omitempty"`
	LastName          string   `json:"family_name,omitempty"`
	Email             string   `json:"email,omitempty"`
	EmailVerified     bool     `json:"email_verified,omitempty"`

	RealmAccess struct {
		Roles []string `json:"roles,omitempty"`
	} `json:"realm_access,omitempty"`
	ResourceAccess struct {
		Account struct {
			Roles []string `json:"roles,omitempty"`
		} `json:"account,omitempty"`
	} `json:"resource_access,omitempty"`
}

func (c *KeycloakClaims) GetRoles() []string {
	return c.RealmAccess.Roles
}
