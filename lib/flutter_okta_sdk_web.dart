import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_okta_sdk/web/okta.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js_util.dart';

class FlutterOktaSdkWeb {
  OktaAuth oktaAuth;

  /// Register Web plugin code in the plugin MethodChannel
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

  /// Initializes authorizer
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

  /// Handles sign in process including redirection to Okta
  Future<void> signIn() async {
    if (oktaAuth.isLoginRedirect()) {
      // promiseToFuture handles conversion of a JavaScript promise to a Dart Future
      promiseToFuture(oktaAuth.storeTokensFromRedirect());
    } else {
      final isAuthenticated = await promiseToFuture(oktaAuth.isAuthenticated());
      if (!isAuthenticated) promiseToFuture(oktaAuth.signInWithRedirect());
    }
  }

  /// Handles sign out process including redirection to Okta
  Future<bool> signOut() async {
    oktaAuth.signOut();

    return true;
  }

  /// Returns if a user is authenticated of not
  Future<bool> isAuthenticated() async {
    return await promiseToFuture(oktaAuth.isAuthenticated());
  }
}
