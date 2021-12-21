

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef AccessTokenProvider = String? Function();
typedef AccessBasicAuthProvider = String? Function();
typedef AccessBaseUrlProvider = String Function();

class ApiClient {
  ApiClient(
      this.baseUrl,
      this.tokenProvider
  ) {
    dio = Dio()
      ..options.baseUrl = baseUrl
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = tokenProvider();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              handler.next(options);
            } else {
              handler.reject(DioError(requestOptions: options));
            }
          },
          onError: (err, handler) {
            if (err.error is SocketException) {
              handler.reject(err);
            }
            if (err.response?.statusCode != null && err.response!.statusCode == 401) {
              handler.reject(err);
            }
          },
        ),
      );
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
        ),
      );
    }
  }
  final String baseUrl;
  final AccessTokenProvider tokenProvider;
  late Dio dio;
}

class ApiBasicClient {
  ApiBasicClient(
      this.baseUrl,
      this.basicAuthProvider
      ) {

    dio = Dio()
      ..options.baseUrl = baseUrl
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final base64 = basicAuthProvider();
            if (base64 != null) {
              options.headers['Authorization'] = 'Basic $base64';
              handler.next(options);
            } else {
              handler.reject(DioError(requestOptions: options));
            }
          },
          onError: (err, handler) {
            if (err.error is SocketException) {
              handler.reject(err);
            }
            if (err.response?.statusCode != null && err.response!.statusCode == 401) {
              handler.reject(err);
            }
            handler.reject(err);
          },
        ),
      );
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
        ),
      );
    }
  }
  final String baseUrl;
  final AccessBasicAuthProvider basicAuthProvider;
  late Dio dio;
}