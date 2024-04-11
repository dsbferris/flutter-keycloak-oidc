# flutter-keycloak-oidc

See [frontend/README.md](frontend/README.md)

## Keycloak config
This example expects two clients in the same realm.

### Frontend Client
- Valid Redirect URIs
  - de.dsbferris.example:/oauth2redirect
  - http://localhost:22433/redirect.html
  - http://localhost:22433
- Valid post logout redirect URIs
  - de.dsbferris.example:/endsessionredirect
  - http://localhost:22433/redirect.html
  - http://localhost:22433
- Web origins
  - http://localhost:22433
- Client authentication: off
- Authentication flow: ONLY Standard flow

If you really need to use the insecure Login Form inside the app, 
enable Client authentication for Credentials and enable Direct access grants.

### Backend Client
- Client authentication: on
- Authentication flow: ONLY Standard flow
