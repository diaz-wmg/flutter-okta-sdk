@JS()
library okta;

import 'package:js/js.dart';

@JS("JSON.stringify")
external String stringify(Object obj);

@JS()
@anonymous
class OktaAuthOptions {
  external String get issuer;
  external set url(String v);
  external String get clientId;
  external set clientId(String v);
  external String get redirectUri;
  external set redirectUri(String v);

  external factory OktaAuthOptions({
    String issuer,
    String clientId,
    String redirectUri,
  });
}

@JS('TokenParams')
@anonymous
abstract class TokenParams {
  external String get responseType;
  external set responseType(String v);

  external factory TokenParams({
    String responseType,
  });
}

@JS('IDToken')
abstract class IDToken {
   external String get clientId;
}

@JS('Tokens')
abstract class Tokens {
  external IDToken get idToken;
}

@JS('TokenResponse')
abstract class TokenResponse {
  external Tokens get tokens;
}

@JS('TokenAPI')
abstract class TokenAPI {
  external Future<void> getWithRedirect(TokenParams options);
  external Future<Tokens> parseFromUrl();
}

@JS('TokenManager')
abstract class TokenManager {
  external factory TokenManager(OktaAuth sdk, OktaAuthOptions options);

  external Future<IDToken> get(String key);
  // TODO: Create IDToken abstract class
  external void add(String key, IDToken token);
}

@JS('OktaAuth')
abstract class OktaAuth {
  external String get userAgent;
  external TokenAPI get token;
  external TokenManager get tokenManager;

  external factory OktaAuth(OktaAuthOptions options);

  external bool isLoginRedirect();
}