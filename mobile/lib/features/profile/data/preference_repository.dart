import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return PreferenceRepository(ref.watch(dioProvider));
});

/// `GET/PUT /api/v1/preferences`. PUT replaces the whole document, so callers
/// send back every field they loaded.
class PreferenceRepository {
  const PreferenceRepository(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> get() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/preferences',
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> replace(Map<String, dynamic> document) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/preferences',
      data: document,
    );
    return _data(response.data);
  }

  static Map<String, dynamic> _data(Map<String, dynamic>? envelope) {
    final data = envelope?['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
