import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'services/cafe_api.dart';
import 'state/favorites_store.dart';
import 'theme.dart';

class SeduhApp extends StatelessWidget {
  const SeduhApp({super.key, required this.api, required this.favorites});
  final CafeApi api;
  final FavoritesStore favorites;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Seduh Surabaya',
    debugShowCheckedModeBanner: false,
    theme: seduhTheme,
    home: ExploreScreen(api: api, favorites: favorites),
  );
}
