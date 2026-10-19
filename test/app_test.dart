import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seduh_surabaya/app.dart';
import 'package:seduh_surabaya/services/cafe_api.dart';
import 'package:seduh_surabaya/state/favorites_store.dart';

const rows = [
  {
    'id': 1,
    'name': 'Kopi Mawar',
    'area': 'Surabaya Barat',
    'address': 'Jl. Mawar',
    'gmaps_review_count': 20,
  },
  {
    'id': 2,
    'name': 'Kopi Melati',
    'area': 'Surabaya Timur',
    'address': 'Jl. Melati',
    'gmaps_review_count': 10,
  },
];
http.Response listing() =>
    http.Response(jsonEncode({'success': true, 'data': rows}), 200);
Future<FavoritesStore> store() async {
  SharedPreferences.setMockInitialValues({});
  return FavoritesStore(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['DMSans', 'Fraunces']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family.ttf'));
      await loader.load();
    }
  });
  testWidgets('shows loading then data and does not refetch when searching', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var requests = 0;
    final api = CafeApi(
      client: MockClient((_) {
        requests++;
        return pending.future;
      }),
    );
    await tester.pumpWidget(SeduhApp(api: api, favorites: await store()));
    expect(find.text('Sedang menyeduh daftar kafe…'), findsOneWidget);
    pending.complete(listing());
    await tester.pumpAndSettle();
    expect(find.text('2 tempat untuk dijelajahi'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('search')), 'mawar');
    await tester.pumpAndSettle();
    expect(find.text('1 tempat untuk dijelajahi'), findsOneWidget);
    expect(requests, 1);
  });
  testWidgets('failed request can be retried successfully', (tester) async {
    var calls = 0;
    final api = CafeApi(
      client: MockClient(
        (_) async => ++calls == 1 ? http.Response('', 500) : listing(),
      ),
    );
    await tester.pumpWidget(SeduhApp(api: api, favorites: await store()));
    await tester.pumpAndSettle();
    expect(find.textContaining('HTTP 500'), findsOneWidget);
    await tester.ensureVisible(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('2 tempat untuk dijelajahi'), findsOneWidget);
  });
  testWidgets('empty API response offers reload', (tester) async {
    final api = CafeApi(
      client: MockClient(
        (_) async => http.Response('{"success":true,"data":[]}', 200),
      ),
    );
    await tester.pumpWidget(SeduhApp(api: api, favorites: await store()));
    await tester.pumpAndSettle();
    expect(find.text('Daftar kafe belum tersedia'), findsOneWidget);
    expect(find.text('Muat ulang'), findsOneWidget);
  });
  testWidgets('area filter, favorites and detail work at mobile width', (
    tester,
  ) async {
    tester.view.reset();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final favorites = await store();
    final api = CafeApi(
      client: MockClient(
        (r) async => r.url.path == '/api/cafes/1'
            ? http.Response(jsonEncode(rows[0]), 200)
            : listing(),
      ),
    );
    await tester.pumpWidget(SeduhApp(api: api, favorites: favorites));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('area-Surabaya Barat')));
    await tester.pumpAndSettle();
    expect(find.text('1 tempat untuk dijelajahi'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(favorites.contains(1), isTrue);
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('1 tempat di favorit'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('open-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-1')));
    await tester.pumpAndSettle();
    expect(find.text('Kenali tempatnya'), findsOneWidget);
    expect(find.text('Kopi Mawar'), findsOneWidget);
    expect(find.text('Harga belum tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('no search results can be reset', (tester) async {
    final api = CafeApi(client: MockClient((_) async => listing()));
    await tester.pumpWidget(SeduhApp(api: api, favorites: await store()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('search')), 'zzzz');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada yang cocok'), findsOneWidget);
    await tester.ensureVisible(find.text('Reset pencarian'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('2 tempat untuk dijelajahi'), findsOneWidget);
  });
}
