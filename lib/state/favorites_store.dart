import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores only IDs. Cafe content always comes from the API.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._preferences) {
    _ids.addAll(
      (_preferences?.getStringList(storageKey) ?? [])
          .map(int.tryParse)
          .whereType<int>(),
    );
  }
  static const storageKey = 'seduh.favorite.ids';
  final SharedPreferences? _preferences;
  final Set<int> _ids = {};
  bool _saving = false;
  Set<int> get ids => Set.unmodifiable(_ids);
  bool contains(int id) => _ids.contains(id);
  bool get saving => _saving;

  Future<void> toggle(int id) async {
    if (_saving) return;
    if (_preferences == null) {
      throw StateError(
        'Penyimpanan perangkat tidak tersedia. Favorit belum disimpan.',
      );
    }
    _saving = true;
    notifyListeners();
    final next = {..._ids};
    next.contains(id) ? next.remove(id) : next.add(id);
    try {
      final saved = await _preferences.setStringList(
        storageKey,
        next.map((id) => '$id').toList(),
      );
      if (!saved) throw StateError('Favorit gagal disimpan. Coba lagi.');
      _ids
        ..clear()
        ..addAll(next);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
