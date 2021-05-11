import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_okta_sdk/web/okta.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js_util.dart';

class FlutterOktaSdkWeb {
  OktaAuth oktaAuth;
  bool isInitialized = false;

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'com.sonikro.flutter_okta_sdk',
      const StandardMethodCodec(),
      registrar,
    );
    final pluginInstance = FlutterOktaSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
       case 'createConfig':
        return createConfig(call.arguments);
        break;
      case 'signIn':
        return signIn();
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'flutter_okta_sdk for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Initializes authorizer
  Future<void> createConfig(Map<dynamic, dynamic> arguments) async {
    this.isInitialized = false;

    final authOptions = new OktaAuthOptions(
      clientId: arguments['clientId'],
      issuer: arguments['discoveryUrl'],
      redirectUri: arguments['redirectUrl'],
    );

    oktaAuth = OktaAuth(authOptions);

    this.isInitialized = true;
  }

  /// Handles sign in process including redirection to Okta
  Future<void> signIn() async {
    if (this.isInitialized == false)
      throw Exception("Cannot sign in before initializing Okta SDK");

    if(oktaAuth.isLoginRedirect()) {
      // promiseToFuture handles conversion of a JavaScript promise to a Dart Future
      final TokenResponse data = await promiseToFuture(oktaAuth.token.parseFromUrl());
      oktaAuth.tokenManager.add('idToken', data.tokens.idToken);
      
      return true;
    } else {
      final IDToken token = await promiseToFuture(oktaAuth.tokenManager.get('idToken'));
      
      if(token != null) {
        return true;
      } else {
        oktaAuth.token.getWithRedirect(new TokenParams(responseType: 'id_token'));
      }
    }
  }
}
