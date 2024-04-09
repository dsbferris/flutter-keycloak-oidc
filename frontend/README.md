# example

An example of how to use flutter with keycloak as oidc provider.

## For linux you need

apt install libsecret-1-dev libjsoncpp-dev

Apart from libsecret you also need a keyring service, for that you need either gnome-keyring (for Gnome users) or ksecretsservice (for KDE users) or other light provider like secret-service.

## Note for web

flutter_secure_storage setup for web

[Source](https://pub.dev/packages/flutter_secure_storage#configure-web-version)

Flutter Secure Storage uses an experimental implementation using WebCrypto. Use at your own risk at this time. Feedback welcome to improve it. The intent is that the browser is creating the private key, and as a result, the encrypted strings in local_storage are not portable to other browsers or other machines and will only work on the same domain.

! It is VERY important that you have HTTP Strict Forward Secrecy enabled and the proper headers applied to your responses or you could be subject to a javascript hijack.

Please see:

    https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
    https://www.netsparker.com/blog/web-security/http-security-headers/
