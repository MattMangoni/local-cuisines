import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:local_cuisines/features/cuisines/data/bestiebite_api_exception.dart';
import 'package:local_cuisines/features/cuisines/data/bestiebite_repository.dart';

void main() {
  group('BestiebiteRepository.autocomplete', () {
    test('parses a populated response into CitySuggestion list', () async {
      const body = '''
      [
        {
          "id": 8047,
          "name": "Milano",
          "description": "Milano, Lombardia, Italia",
          "latitude": 45.4612939,
          "longitude": 9.172356290785304,
          "country_code": "IT",
          "structured_formatting": {
            "main_text": "Milano",
            "secondary_text": "Lombardia, Italia"
          }
        }
      ]
      ''';
      final client = MockClient((request) async {
        expect(request.url.path, '/places/v2/autocomplete');
        expect(request.url.queryParameters['term'], 'mila');
        expect(request.url.queryParameters['lang'], 'it');
        expect(request.url.queryParameters['limit'], '8');
        return http.Response(body, 200, headers: _jsonHeaders);
      });
      final repo = BestiebiteRepository(client);

      final result = await repo.autocomplete('mila');

      expect(result, hasLength(1));
      final milano = result.single;
      expect(milano.id, 8047);
      expect(milano.name, 'Milano');
      expect(milano.mainText, 'Milano');
      expect(milano.secondaryText, 'Lombardia, Italia');
      expect(milano.latitude, closeTo(45.4612939, 1e-6));
      expect(milano.longitude, closeTo(9.172356290785304, 1e-6));
    });

    test('returns an empty list when the API returns []', () async {
      final client = MockClient((_) async => http.Response('[]', 200, headers: _jsonHeaders));
      final repo = BestiebiteRepository(client);

      final result = await repo.autocomplete('a');

      expect(result, isEmpty);
    });

    test('throws BestiebiteApiException on non-2xx status', () async {
      final client = MockClient((_) async => http.Response('boom', 500));
      final repo = BestiebiteRepository(client);

      await expectLater(
        () => repo.autocomplete('mila'),
        throwsA(
          isA<BestiebiteApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('BestiebiteRepository.cuisinesByLocation', () {
    test('parses {length, data} response into Cuisine list', () async {
      const body = '''
      {
        "length": 1,
        "data": [
          {
            "id": 52,
            "name": "Cinese",
            "name_it": "Cinese",
            "name_eng": "Chinese",
            "name_es": "China",
            "color": "#5B50A1",
            "image_emoji": "https://example.com/cucina_cinese.png",
            "type": "cuisine",
            "eng_label": "chinese"
          }
        ]
      }
      ''';
      final client = MockClient((request) async {
        expect(request.url.path, '/places/labels/by-location-and-type');
        expect(request.url.queryParameters['lat'], '45.46');
        expect(request.url.queryParameters['lng'], '9.17');
        expect(request.url.queryParameters['type'], 'cuisine');
        return http.Response(body, 200, headers: _jsonHeaders);
      });
      final repo = BestiebiteRepository(client);

      final result = await repo.cuisinesByLocation(45.46, 9.17);

      expect(result, hasLength(1));
      final cinese = result.single;
      expect(cinese.id, 52);
      expect(cinese.name, 'Cinese');
      expect(cinese.imageUrl, 'https://example.com/cucina_cinese.png');
    });

    test('falls back to name when name_it is missing', () async {
      const body = '''
      {
        "length": 1,
        "data": [
          {"id": 1, "name": "Pizza", "image_emoji": "https://example.com/pizza.png"}
        ]
      }
      ''';
      final client = MockClient((_) async => http.Response(body, 200, headers: _jsonHeaders));
      final repo = BestiebiteRepository(client);

      final result = await repo.cuisinesByLocation(0, 0);

      expect(result.single.name, 'Pizza');
    });
  });
}

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};
