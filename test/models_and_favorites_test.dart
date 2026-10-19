import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seduh_surabaya/models/cafe.dart';
import 'package:seduh_surabaya/models/cafe_filter.dart';
import 'package:seduh_surabaya/state/favorites_store.dart';

void main() {
  const cafes = [
    Cafe(
      id: 1,
      name: 'Kopi Satu',
      area: 'Surabaya Barat',
      address: 'Jl. Mawar',
      rating: 4,
      reviewCount: 50,
    ),
    Cafe(
      id: 2,
      name: 'Kopi Dua',
      area: 'Surabaya Timur',
      rating: 5,
      reviewCount: 2,
    ),
    Cafe(id: 3, name: 'Teh Tiga', area: 'Surabaya Barat', reviewCount: 10),
  ];
  test('optional missing fields have honest fallbacks', () {
    final c = Cafe.fromJson({'id': '1', 'name': 'Kafe'});
    expect(c.displayPrice, 'Harga belum tersedia');
    expect(c.displayHours, 'Jam operasional belum tersedia');
    expect(c.rating, isNull);
    expect(c.mapsUri, isNull);
  });
  test('invalid primary fields fail parsing', () {
    expect(() => Cafe.fromJson({'name': 'Kafe'}), throwsFormatException);
  });
  test('invalid rating is treated as missing', () {
    expect(
      Cafe.fromJson({'id': 1, 'name': 'Kafe', 'gmaps_rating': 9}).rating,
      isNull,
    );
  });
  test(
    'search combines terms, is insensitive to case and searches addresses',
    () {
      expect(filterCafes(cafes, query: '  KOPI   mawar ').map((c) => c.id), [
        1,
      ]);
    },
  );
  test('area, keyword and favorites combine correctly', () {
    expect(
      filterCafes(
        cafes,
        query: 'kopi',
        area: 'Surabaya Timur',
        favoriteIds: {1, 2},
      ).map((c) => c.id),
      [2],
    );
  });
  test('unmatched query returns empty', () {
    expect(filterCafes(cafes, query: 'xyz123'), isEmpty);
  });
  test('sort uses complete list and never mutates the source', () {
    expect(filterCafes(cafes).map((c) => c.id), [1, 3, 2]);
    expect(filterCafes(cafes, sort: CafeSort.rating).map((c) => c.id), [
      2,
      1,
      3,
    ]);
    expect(filterCafes(cafes, sort: CafeSort.name).map((c) => c.id), [2, 1, 3]);
    expect(cafes.first.id, 1);
  });
  test(
    'unsafe URL scheme is rejected; valid coordinates use a Maps fallback',
    () {
      const bad = Cafe(
        id: 1,
        name: 'Kafe',
        area: '',
        mapsUrl: 'javascript:alert(1)',
      );
      expect(bad.mapsUri, isNull);
      const fallback = Cafe(
        id: 1,
        name: 'Kafe',
        area: '',
        latitude: -7.2,
        longitude: 112.7,
      );
      expect(fallback.mapsUri?.queryParameters['query'], '-7.2,112.7');
      const invalid = Cafe(
        id: 1,
        name: 'Kafe',
        area: '',
        latitude: 999,
        longitude: 112.7,
      );
      expect(invalid.mapsUri, isNull);
    },
  );
  test('favorites persist across store instances and can be removed', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = FavoritesStore(preferences);
    await store.toggle(42);
    expect(store.contains(42), isTrue);
    final restored = FavoritesStore(preferences);
    expect(restored.contains(42), isTrue);
    await restored.toggle(42);
    expect(restored.ids, isEmpty);
    expect(preferences.getStringList(FavoritesStore.storageKey), isEmpty);
  });
  test('unavailable storage never claims that a favorite was saved', () async {
    final store = FavoritesStore(null);
    await expectLater(store.toggle(42), throwsStateError);
    expect(store.ids, isEmpty);
  });
}
