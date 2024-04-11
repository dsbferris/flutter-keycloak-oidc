import 'package:dio/dio.dart';
import 'package:example/provider/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api.g.dart';

@RestApi(baseUrl: "http://localhost:8080")
abstract class ApiRepository {
  factory ApiRepository(Dio dio) = _ApiRepository;

  @GET('/')
  Future<String> getPublic();

  @GET('/protected')
  Future<String> getProtected();
}

@riverpod
Future<String> publicApi(PublicApiRef ref) {
  return ApiRepository(ref.watch(dioClientProvider)).getPublic();
}

@riverpod
Future<String> protectedApi(ProtectedApiRef ref) async {
  final dio = await ref.watch(dioAuthClientProvider.future);
  return await ApiRepository(dio).getProtected();
}
