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
      case 'revokeAccessToken':
        return revokeAccessToken();
        break;
      case 'revokeRefreshToken':
        return revokeRefreshToken();
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

  // TODO: Implement introspectAccessToken
  Future<String> introspectAccessToken() async {}

  // TODO: Implement introspectIdToken
  Future<String> introspectIdToken() async {}

  // TODO: Implement introspectRefreshToken
  Future<String> introspectRefreshToken() async {}

  // TODO: Implement refreshTokens
  Future<String> refreshTokens() async {}

  Future<bool> revokeAccessToken() async {
    await promiseToFuture(oktaAuth.revokeAccessToken());
    return true;
  }

  // TODO: Implement revokeIdToken
  Future<bool> revokeIdToken() async {}

  Future<bool> revokeRefreshToken() async {
    await promiseToFuture(oktaAuth.revokeRefreshToken());
    return true;
  }

  // TODO: Implement clearTokens
  Future<bool> clearTokens() async {}

  Future<bool> signOut() async {
    oktaAuth.signOut();

    return true;
  }
}
