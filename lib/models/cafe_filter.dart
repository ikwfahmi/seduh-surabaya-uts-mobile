import 'cafe.dart';

enum CafeSort {
  popular('Paling banyak diulas'),
  rating('Rating tertinggi'),
  name('Nama A–Z');

  const CafeSort(this.label);
  final String label;
}

List<Cafe> filterCafes(
  List<Cafe> source, {
  String query = '',
  String? area,
  Set<int>? favoriteIds,
  CafeSort sort = CafeSort.popular,
}) {
  final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
  final result = source.where((cafe) {
    final haystack =
        '${cafe.name} ${cafe.address} ${cafe.category} ${cafe.area}'
            .toLowerCase();
    return (area == null || cafe.area == area) &&
        (favoriteIds == null || favoriteIds.contains(cafe.id)) &&
        words.every(haystack.contains);
  }).toList();
  result.sort((a, b) {
    final order = switch (sort) {
      CafeSort.popular => b.reviewCount.compareTo(a.reviewCount),
      CafeSort.rating => (b.rating ?? -1).compareTo(a.rating ?? -1),
      CafeSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
    return order != 0 ? order : a.id.compareTo(b.id);
  });
  return result;
}
