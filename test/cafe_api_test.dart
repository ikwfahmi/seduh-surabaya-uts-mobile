import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seduh_surabaya/services/cafe_api.dart';

void main() {
  final sample = File('test/fixtures/cafes.json').readAsStringSync();
  final detail = File('test/fixtures/detail.json').readAsStringSync();
  http.Response response(String body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(body), status);

  test('parses real API envelope, Unicode and numeric values', () async {
    final api = CafeApi(
      client: MockClient((request) async {
        expect(request.url.host, 'surabaya-cafe-api.vercel.app');
        expect(request.url.queryParameters['page'], '1');
        final page = jsonDecode(sample) as Map<String, dynamic>;
        page['total_pages'] = 1;
        return response(jsonEncode(page));
      }),
    );
    final cafes = await api.fetchCafes();
    expect(cafes.length, 2);
    expect(cafes.first.rating, 4.0);
    expect(cafes.first.priceRange, contains('50–150'));
    expect(cafes.last.priceRange, isEmpty);
    api.close();
  });
  test('follows pagination when API has multiple pages', () async {
    var calls = 0;
    final api = CafeApi(
      client: MockClient((r) async {
        calls++;
        return response(
          jsonEncode({
            'success': true,
            'total_pages': 2,
            'data': [
              {'id': calls, 'name': 'Kafe $calls'},
            ],
          }),
        );
      }),
    );
    expect((await api.fetchCafes()).map((e) => e.id), [1, 2]);
    expect(calls, 2);
  });
  test('handles a valid empty dataset', () async {
    final api = CafeApi(
      client: MockClient(
        (_) async => response('{"success":true,"data":[],"total_pages":1}'),
      ),
    );
    expect(await api.fetchCafes(), isEmpty);
  });
  test('parses detail response without list envelope', () async {
    final api = CafeApi(client: MockClient((_) async => response(detail)));
    expect((await api.fetchCafe(428173890)).name, contains('Kollabora'));
  });
  for (final status in [404, 429, 500]) {
    test('HTTP $status produces a readable error', () async {
      final api = CafeApi(
        client: MockClient((_) async => response('{}', status)),
      );
      await expectLater(api.fetchCafes(), throwsA(isA<CafeApiException>()));
    });
  }
  for (final body in [
    '<html>error</html>',
    '[]',
    '{"success":false,"data":[]}',
    '{"success":true,"data":[{}]}',
    '{"success":true,"data":[7]}',
    '{"success":true,"data":[],"total_pages":2000}',
  ]) {
    test('rejects invalid JSON/schema: $body', () async {
      final api = CafeApi(client: MockClient((_) async => response(body)));
      await expectLater(api.fetchCafes(), throwsA(isA<CafeApiException>()));
    });
  }
  test('detail rejects a mismatched ID', () async {
    final api = CafeApi(client: MockClient((_) async => response(detail)));
    await expectLater(api.fetchCafe(123), throwsA(isA<CafeApiException>()));
  });
  test('network failure is translated', () async {
    final api = CafeApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(api.fetchCafes(), throwsA(isA<CafeApiException>()));
  });
  test('slow request times out', () async {
    final pending = Completer<http.Response>();
    final api = CafeApi(
      client: MockClient((_) => pending.future),
      timeout: const Duration(milliseconds: 5),
    );
    await expectLater(api.fetchCafes(), throwsA(isA<CafeApiException>()));
    pending.complete(response('{}'));
  });
}
