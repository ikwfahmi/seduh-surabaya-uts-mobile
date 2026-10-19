import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/cafe_api.dart';
import 'state/favorites_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (_) {
    // Browsers with blocked storage can still browse; saving reports the issue.
  }
  runApp(SeduhApp(api: CafeApi(), favorites: FavoritesStore(preferences)));
}
