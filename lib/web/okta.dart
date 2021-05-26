@JS()
library okta;

import 'package:js/js.dart';

@JS('OktaAuthOptions')
@anonymous
class OktaAuthOptions {
  external String get issuer;
  external set url(String issuer);
  external String get clientId;
  external set clientId(String clientId);
  external String get redirectUri;
  external set redirectUri(String redirectUri);
  external String get postLogoutRedirectUri;
  external set postLogoutRedirectUri(String postLogoutRedirectUri);
  external List<dynamic> get scopes;
  external set scopes(List<dynamic> scopes);

  external factory OktaAuthOptions({
    String issuer,
    String clientId,
    String redirectUri,
    String postLogoutRedirectUri,
    List<dynamic> scopes,
  });
}

// TODO: Possible expand specification
@JS('IDToken')
abstract class IDToken {
  external String get clientId;
}

// TODO: Possible expand specification
@JS('Token')
abstract class Token {}

@JS('TokenAPI')
abstract class TokenAPI {
  external Future<IDToken> verify(IDToken verify);
}

@JS('TokenManager')
abstract class TokenManager {
  external factory TokenManager(OktaAuth sdk, OktaAuthOptions options);

  external Future<IDToken> get(String key);
  external Future<Token> renew(String key);
  external void clear();
}

@JS('OktaAuth')
abstract class OktaAuth {
  external TokenAPI get token;
  external TokenManager get tokenManager;

  external factory OktaAuth(OktaAuthOptions options);

  external bool isLoginRedirect();
  external Future<void> signInWithRedirect();
  external Future<void> storeTokensFromRedirect();
  external Future<void> handleLoginRedirect();
  external Future<bool> isAuthenticated();
  external String getAccessToken();
  external String getIdToken();
  external Future<dynamic> revokeAccessToken();
  external Future<dynamic> revokeRefreshToken();
  external void signOut();
}
