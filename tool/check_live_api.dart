import 'dart:convert';
import 'dart:io';

import 'package:seduh_surabaya/services/cafe_api.dart';
import 'package:seduh_surabaya/models/cafe_filter.dart';

Future<void> main() async {
  final api = CafeApi();
  try {
    final all = await api.fetchCafes();
    if (all.isEmpty) throw StateError('API returned no cafes');
    final matches = filterCafes(all, query: 'kopi tuku');
    final detail = await api.fetchCafe(
      (matches.isNotEmpty ? matches.first : all.first).id,
    );
    final result = {
      'checked_at_utc': DateTime.now().toUtc().toIso8601String(),
      'total_received': all.length,
      'areas': all.map((e) => e.area).toSet().toList()..sort(),
      'search_kopi_tuku_count': matches.length,
      'detail_id': detail.id,
      'detail_name': detail.name,
      'maps_url_valid': detail.mapsUri != null,
    };
    final json = const JsonEncoder.withIndent('  ').convert(result);
    stdout.writeln(json);
    if (Platform.environment['SAVE_API_EVIDENCE'] == '1') {
      File('docs/live-api-check.json').writeAsStringSync('$json\n');
    }
  } finally {
    api.close();
  }
}
