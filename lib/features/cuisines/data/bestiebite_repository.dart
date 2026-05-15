import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/http_client.dart';
import 'bestiebite_api_exception.dart';
import 'city_suggestion.dart';
import 'cuisine.dart';

class BestiebiteRepository {
  BestiebiteRepository(this._client);

  final http.Client _client;
  static const _baseUrl = 'https://api.bestiebite.com';

  Future<List<CitySuggestion>> autocomplete(
    String term, {
    String lang = 'it',
    int limit = 8,
  }) async {
    final uri = Uri.parse('$_baseUrl/places/v2/autocomplete').replace(
      queryParameters: {
        'term': term,
        'lang': lang,
        'limit': '$limit',
      },
    );
    
    final response = await _client.get(uri);
    _ensureSuccess(response);
    final list = jsonDecode(response.body) as List<dynamic>;

    return list
        .cast<Map<String, dynamic>>()
        .map(CitySuggestion.fromJson)
        .toList();
  }

  Future<List<Cuisine>> cuisinesByLocation(double lat, double lng) async {
    final uri = Uri.parse('$_baseUrl/places/labels/by-location-and-type').replace(
      queryParameters: {
        'lat': '$lat',
        'lng': '$lng',
        'type': 'cuisine',
      },
    );

    final response = await _client.get(uri);
    _ensureSuccess(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? const [];

    return data
        .cast<Map<String, dynamic>>()
        .map(Cuisine.fromJson)
        .toList();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BestiebiteApiException(
        statusCode: response.statusCode,
        message: 'Request failed: ${response.request?.url}',
      );
    }
  }
}

final bestiebiteRepositoryProvider = Provider<BestiebiteRepository>((ref) {
  return BestiebiteRepository(ref.watch(httpClientProvider));
});
