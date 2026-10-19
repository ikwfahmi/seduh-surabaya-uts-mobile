import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cafe.dart';
import '../models/cafe_filter.dart';
import '../services/cafe_api.dart';
import '../state/favorites_store.dart';
import '../theme.dart';
import '../widgets/cafe_card.dart';
import '../widgets/coffee_art.dart';
import '../widgets/feedback_panel.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.api, required this.favorites});
  final CafeApi api;
  final FavoritesStore favorites;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Cafe>> _future;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String? _area;
  CafeSort _sort = CafeSort.popular;
  bool _favoritesOnly = false;
  int _visible = 24;

  @override
  void initState() {
    super.initState();
    // Create the Future once; typing and rebuilding never restart the request.
    _future = widget.api.fetchCafes();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.api.fetchCafes();
      _visible = 24;
    });
    try {
      await _future;
    } catch (_) {
      /* FutureBuilder displays the error. */
    }
  }

  void _switchTab(bool value) {
    if (_favoritesOnly == value) return;
    setState(() {
      _favoritesOnly = value;
      _area = null;
      _search.clear();
      _visible = 24;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _clearFilters() => setState(() {
    _search.clear();
    _area = null;
    _sort = CafeSort.popular;
    _visible = 24;
  });
  Future<void> _toggle(Cafe cafe) async {
    final wasSaved = widget.favorites.contains(cafe.id);
    try {
      await widget.favorites.toggle(cafe.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              wasSaved
                  ? 'Kafe dihapus dari favorit.'
                  : 'Kafe disimpan ke favorit.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final wide = bounds.maxWidth >= 760;
      final horizontal = math.max(
        wide ? 32.0 : 20.0,
        (bounds.maxWidth - 1140) / 2,
      );
      return ListenableBuilder(
        listenable: widget.favorites,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            toolbarHeight: wide ? 90 : 76,
            automaticallyImplyLeading: false,
            titleSpacing: horizontal,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SeduhColors.coffee,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.coffee_rounded,
                    color: SeduhColors.paper,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('seduh.', style: editorial(27)),
                    const Text(
                      'SURABAYA',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 2.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (wide) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () => _switchTab(false),
                    child: Text(
                      'Jelajahi',
                      style: TextStyle(
                        fontWeight: _favoritesOnly
                            ? FontWeight.w400
                            : FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  TextButton.icon(
                    onPressed: () => _switchTab(true),
                    icon: const Icon(Icons.bookmark_border_rounded, size: 19),
                    label: Text('Favorit (${widget.favorites.ids.length})'),
                  ),
                  const SizedBox(width: 16),
                ] else
                  const Spacer(),
                IconButton(
                  tooltip: 'Muat ulang data',
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded, size: 23),
                ),
                IconButton(
                  tooltip: 'Tentang aplikasi',
                  onPressed: _showAbout,
                  icon: const Icon(Icons.info_outline_rounded, size: 23),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: SeduhColors.line)),
                  ),
                  child: NavigationBar(
                    selectedIndex: _favoritesOnly ? 1 : 0,
                    onDestinationSelected: (i) => _switchTab(i == 1),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: 'Jelajahi',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.bookmark_border_rounded),
                        selectedIcon: Icon(Icons.bookmark_rounded),
                        label: 'Favorit',
                      ),
                    ],
                  ),
                ),
          body: FutureBuilder<List<Cafe>>(
            future: _future,
            builder: (context, snapshot) {
              final all = snapshot.data ?? <Cafe>[];
              final areas =
                  all
                      .map((c) => c.area)
                      .where((v) => v.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
              final results = filterCafes(
                all,
                query: _search.text,
                area: _area,
                favoriteIds: _favoritesOnly ? widget.favorites.ids : null,
                sort: _sort,
              );
              final contentWidth = bounds.maxWidth - 2 * horizontal;
              final columns = contentWidth >= 1000
                  ? 3
                  : contentWidth >= 620
                  ? 2
                  : 1;
              final count = math.min(_visible, results.length);
              final scale = MediaQuery.textScalerOf(context).scale(1);
              return RefreshIndicator(
                onRefresh: _reload,
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        8,
                        horizontal,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _hero(wide, all, areas),
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SliverToBoxAdapter(child: LoadingPanel())
                    else if (snapshot.hasError)
                      SliverToBoxAdapter(
                        child: FeedbackPanel(
                          icon: Icons.wifi_off_rounded,
                          title: 'Kopi boleh jeda. Koneksi juga.',
                          message: '${snapshot.error}',
                          action: _reload,
                        ),
                      )
                    else if (all.isEmpty)
                      SliverToBoxAdapter(
                        child: FeedbackPanel(
                          icon: Icons.local_cafe_outlined,
                          title: 'Daftar kafe belum tersedia',
                          message: 'Server belum mengirim data kafe. Silakan muat ulang beberapa saat lagi.',
                          action: _reload,
                          actionLabel: 'Muat ulang',
                        ),
                      )
                    else ...[
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          28,
                          horizontal,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              TextField(
                                key: const ValueKey('search'),
                                controller: _search,
                                onChanged: (_) => setState(() => _visible = 24),
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari nama kafe, alamat, atau kategori…',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _search.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'Hapus pencarian',
                                          icon: const Icon(Icons.close_rounded),
                                          onPressed: () => setState(() {
                                            _search.clear();
                                            _visible = 24;
                                          }),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 54 * scale,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [null, ...areas].map((area) {
                                    final selected = _area == area;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        key: ValueKey('area-${area ?? 'all'}'),
                                        selected: selected,
                                        showCheckmark: false,
                                        label: Text(
                                          area == null
                                              ? 'Semua wilayah'
                                              : area.replaceFirst(
                                                  'Surabaya ',
                                                  '',
                                                ),
                                          style: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : SeduhColors.ink,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onSelected: (_) => setState(() {
                                          _area = area;
                                          _visible = 24;
                                        }),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _favoritesOnly
                                              ? 'Koleksi favoritmu'
                                              : 'Temukan tempatmu',
                                          style: editorial(wide ? 29 : 25),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${results.length} tempat ${_favoritesOnly ? 'di favorit' : 'untuk dijelajahi'}',
                                          key: const ValueKey('result-count'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: SeduhColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<CafeSort>(
                                    tooltip: 'Urutkan kafe',
                                    initialValue: _sort,
                                    onSelected: (v) => setState(() {
                                      _sort = v;
                                      _visible = 24;
                                    }),
                                    itemBuilder: (_) => CafeSort.values
                                        .map(
                                          (v) => CheckedPopupMenuItem(
                                            value: v,
                                            checked: v == _sort,
                                            child: Text(v.label),
                                          ),
                                        )
                                        .toList(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.sort_rounded,
                                            size: 21,
                                          ),
                                          if (wide) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              _sort.label,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.expand_more_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                      if (results.isEmpty)
                        SliverToBoxAdapter(
                          child: FeedbackPanel(
                            icon: _favoritesOnly
                                ? Icons.bookmark_border_rounded
                                : Icons.search_off_rounded,
                            title:
                                _favoritesOnly && widget.favorites.ids.isEmpty
                                ? 'Simpan tempat yang kamu suka'
                                : 'Belum ada yang cocok',
                            message:
                                _favoritesOnly && widget.favorites.ids.isEmpty
                                ? 'Ketuk ikon penanda pada kafe pilihanmu. Daftarnya akan tersimpan di perangkat ini.'
                                : 'Coba kata kunci lain atau pilih wilayah yang berbeda.',
                            action:
                                _favoritesOnly && widget.favorites.ids.isEmpty
                                ? () => _switchTab(false)
                                : _clearFilters,
                            actionLabel:
                                _favoritesOnly && widget.favorites.ids.isEmpty
                                ? 'Jelajahi kafe'
                                : 'Reset pencarian',
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontal),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final cafe = results[index];
                              return CafeCard(
                                cafe: cafe,
                                favorite: widget.favorites.contains(cafe.id),
                                saving: widget.favorites.saving,
                                onFavorite: () => _toggle(cafe),
                                onOpen: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(
                                      id: cafe.id,
                                      api: widget.api,
                                      favorites: widget.favorites,
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: count),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  mainAxisExtent:
                                      268 + math.max(0, scale - 1) * 180,
                                ),
                          ),
                        ),
                      if (count < results.length)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _visible += 24),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(
                                  'Tampilkan lagi (${results.length - count} lainnya)',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          30,
                          horizontal,
                          30,
                        ),
                        child: const Text(
                          'Dari Surabaya, untuk jeda yang lebih bermakna.\nData: Surabaya Cafe API · Tampilan ilustratif',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: SeduhColors.muted,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );

  Widget _hero(bool wide, List<Cafe> all, List<String> areas) => Container(
    padding: EdgeInsets.all(wide ? 36 : 24),
    decoration: BoxDecoration(
      color: const Color(0xFFF0EADD),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: SeduhColors.line),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, size: 6, color: SeduhColors.sage),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'JEDA SEJENAK, JELAJAH LEBIH JAUH',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: SeduhColors.sage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _favoritesOnly
                    ? 'Tempat favorit,\ncerita berikutnya.'
                    : 'Secangkir kopi.\nSejuta cerita.',
                style: editorial(wide ? 53 : 36),
              ),
              const SizedBox(height: 14),
              Text(
                _favoritesOnly
                    ? 'Kafe pilihanmu, tersimpan untuk kunjungan berikutnya.'
                    : 'Temukan sudut nyaman untuk ngopi, berbincang,\ndan menikmati Surabaya dengan caramu.',
                style: const TextStyle(
                  fontSize: 13,
                  color: SeduhColors.muted,
                  height: 1.7,
                ),
              ),
              if (all.isNotEmpty) ...[
                const SizedBox(height: 21),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    Text(
                      '${all.length} tempat',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${areas.length} wilayah',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SeduhColors.muted,
                      ),
                    ),
                    const Text(
                      'Tanpa perlu akun',
                      style: TextStyle(fontSize: 12, color: SeduhColors.muted),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (wide) ...[
          const SizedBox(width: 20),
          const CoffeeArt(size: 220),
          const SizedBox(width: 24),
        ],
      ],
    ),
  );

  void _showAbout() => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Dibuat untuk jedamu.', style: editorial(28)),
      content: const SingleChildScrollView(
        child: Text(
          'Seduh Surabaya membantu menemukan kafe dan tempat makan dari data terbuka Surabaya Cafe API.\n\n'
          'Rating, alamat, harga, serta jam operasional mengikuti data sumber dan dapat berubah. '
          'Periksa Google Maps sebelum berkunjung. Ilustrasi bukan foto tempat.\n\n'
          'Favorit hanya disimpan pada perangkat/browser ini. Daftar kafe membutuhkan internet.\n\n'
          'Sumber: surabaya-cafe-api.vercel.app\nPenyedia API: Reyhandhani · Lisensi MIT\n\n'
          'UTS Pemrograman Mobile · Flutter & Dart',
          style: TextStyle(height: 1.6),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kembali jelajah'),
        ),
      ],
    ),
  );
}
