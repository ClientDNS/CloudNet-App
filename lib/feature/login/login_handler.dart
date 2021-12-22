import 'dart:convert';


import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:localstorage/localstorage.dart';

import '/feature/node/node_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

LoginHandler loginHandler = LoginHandler();

class LoginHandler extends ValueNotifier<bool> {
  LoginHandler() : super(false);
  String? _token;

  String? accessToken() => _token ?? '';

  Future<void> load() async {
    final storage = LocalStorage('token.json');
    await storage.ready;
    final dynamic token = await storage.getItem('token');
    if (token != null && token is String) {
      _token = token;
    }
  }

  Future<void> _save(String token) async {
    final storage = LocalStorage('token.json');
    await storage.ready;
    await storage.setItem('token', token);
  }

  Future<String> handleLogin(String username, String password) async {
    final token = await Dio()
        .postUri<String>(
          Uri.parse('${nodeHandler.currentBaseUrl()}/api/v2/auth'),
          data: <String, dynamic>{},
          options: Options(headers: <String, dynamic>{
            'Authorization':
                'Basic ${base64.encode(utf8.encode('$username:$password'))}',
          }),
        )
        .then((response) => response.data!);
    final Map<String, dynamic> response =
        jsonDecode(token) as Map<String, dynamic>;
    _token = response['token'] as String;
    await _save(_token!);
    value = true;
    return _token!;
  }

  bool isExpired() {
    return _token != null && JwtDecoder.isExpired(_token!);
  }
}
