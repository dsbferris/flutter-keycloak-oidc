import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:example/logger.dart';
import 'package:example/provider/oidc_provider.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) => Dio();

@riverpod
Dio dioAuthClient(DioAuthClientRef ref) {
  final accessToken = ref.watch(accessTokenProvider);
  if (accessToken == null) {
    throw Exception(
        "access token must not be null for an authenticated request!");
  }
  final dio = Dio();
  dio.interceptors.add(AuthenticatorInterceptor(accessToken, dio));
  return dio;
}

class AuthenticatorInterceptor extends Interceptor {
  final String? accessToken;
  final Dio dio;

  AuthenticatorInterceptor(this.accessToken, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (accessToken == null) {
      handler.reject(DioException.requestCancelled(
          requestOptions: options, reason: "access token must not be null"));
      return;
    }

    // if there was no error you can move on with your request with the new token (if any)
    options.headers.putIfAbsent("Authorization", () => "Bearer $accessToken");
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    logger.e("DioException:\n$err\n\nHandler:\n$handler");
    return super.onError(err, handler);
  }
}