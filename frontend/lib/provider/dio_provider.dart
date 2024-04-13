import 'package:dio/dio.dart';
import 'package:example/provider/oidc_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/logger.dart';

part 'dio_provider.g.dart';

// It is better to have two Dio instances,
// one for normal/un-authenticated request
// and one for authenticated requests

@riverpod
Dio dioClient(DioClientRef ref) => Dio();

@riverpod
Dio dioAuthClient(DioAuthClientRef ref) {
  final user = ref.watch(userProvider);
  final accessToken = user?.token.accessToken;
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
