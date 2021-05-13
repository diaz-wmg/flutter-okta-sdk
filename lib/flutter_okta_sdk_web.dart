import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_okta_sdk/web/okta.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js_util.dart';

class FlutterOktaSdkWeb {
  OktaAuth oktaAuth;

  /// Register Web plugin code in the MethodChannel of the plugin
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'com.sonikro.flutter_okta_sdk',
      const StandardMethodCodec(),
      registrar,
    );
    final pluginInstance = FlutterOktaSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handle web method calls from main plugin file
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'createConfig':
        return createConfig(call.arguments);
        break;
      case 'signIn':
        return signIn();
        break;
      case 'isAuthenticated':
        return isAuthenticated();
        break;
      case 'getAccessToken':
        return getAccessToken();
        break;
      case 'getIdToken':
        return getIdToken();
        break;
      case 'introspectIdToken':
        return introspectIdToken();
        break;
      case 'refreshTokens':
        return refreshTokens();
        break;
      case 'revokeAccessToken':
        return revokeAccessToken();
        break;
      case 'revokeRefreshToken':
        return revokeRefreshToken();
        break;
      case 'clearTokens':
        return clearTokens();
        break;
      case 'signOut':
        return signOut();
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'flutter_okta_sdk for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Initializes Okta client
  Future<void> createConfig(Map<dynamic, dynamic> arguments) async {
    final authOptions = new OktaAuthOptions(
      clientId: arguments['clientId'],
      issuer: arguments['discoveryUrl'],
      redirectUri: arguments['redirectUrl'],
      postLogoutRedirectUri: arguments['endSessionRedirectUri'],
      scopes: arguments['scopes'],
    );

    oktaAuth = OktaAuth(authOptions);
  }

  Future<void> signIn() async {
    if (oktaAuth.isLoginRedirect()) {
      // promiseToFuture handles conversion of a JavaScript promise to a Dart Future
      promiseToFuture(oktaAuth.storeTokensFromRedirect());
      // Documentation says use this one
      // promiseToFuture(oktaAuth.handleLoginRedirect());
    } else {
      final isAuthenticated = await promiseToFuture(oktaAuth.isAuthenticated());
      if (!isAuthenticated) promiseToFuture(oktaAuth.signInWithRedirect());
    }
  }

  Future<bool> isAuthenticated() async {
    return await promiseToFuture(oktaAuth.isAuthenticated());
  }

  Future<String> getAccessToken() async {
    return oktaAuth.getAccessToken();
  }

  Future<String> getIdToken() async {
    return oktaAuth.getIdToken();
  }

  // TODO: Not Supported by JavaScript library
  Future<String> introspectAccessToken() async {}

  Future<String> introspectIdToken() async {
    final IDToken token =
        await promiseToFuture(oktaAuth.tokenManager.get('idToken'));
    final IDToken tokenResult =
        await promiseToFuture(oktaAuth.token.verify(token));

    if (tokenResult != null) return "token is valid";

    return "token is invalid";
  }

  // TODO: Not Supported by JavaScript library
  Future<String> introspectRefreshToken() async {}

  Future<String> refreshTokens() async {
    await promiseToFuture(oktaAuth.tokenManager.renew('idToken'));
    await promiseToFuture(oktaAuth.tokenManager.renew('accessToken'));

    return 'Token refreshed!';
  }

  Future<bool> revokeAccessToken() async {
    await promiseToFuture(oktaAuth.revokeAccessToken());

    return true;
  }

  // TODO: Not Supported by JavaScript library
  Future<bool> revokeIdToken() async {}

  Future<bool> revokeRefreshToken() async {
    await promiseToFuture(oktaAuth.revokeRefreshToken());

    return true;
  }

  Future<bool> clearTokens() async {
    oktaAuth.tokenManager.clear();

    return true;
  }

  Future<bool> signOut() async {
    oktaAuth.signOut();

    return true;
  }
}
