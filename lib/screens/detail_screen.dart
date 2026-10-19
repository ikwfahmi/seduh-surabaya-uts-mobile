import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cafe.dart';
import '../services/cafe_api.dart';
import '../state/favorites_store.dart';
import '../theme.dart';
import '../widgets/coffee_art.dart';
import '../widgets/feedback_panel.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.id,
    required this.api,
    required this.favorites,
  });
  final int id;
  final CafeApi api;
  final FavoritesStore favorites;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Cafe> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchCafe(widget.id);
  }

  void _retry() => setState(() => _future = widget.api.fetchCafe(widget.id));
  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _save() async {
    try {
      await widget.favorites.toggle(widget.id);
    } catch (_) {
      _message('Favorit belum dapat disimpan. Periksa penyimpanan perangkat.');
    }
  }

  Future<void> _openMaps(Cafe cafe) async {
    final uri = cafe.mapsUri;
    if (uri == null) return;
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message('Google Maps tidak dapat dibuka. Coba salin alamatnya.');
      }
    } catch (_) {
      _message('Google Maps tidak dapat dibuka. Coba salin alamatnya.');
    }
  }

  Future<void> _copy(Cafe cafe) async {
    try {
      await Clipboard.setData(
        ClipboardData(text: '${cafe.name}\n${cafe.address}\n${cafe.area}'),
      );
      _message('Alamat disalin.');
    } catch (_) {
      _message('Alamat belum dapat disalin.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kenali tempatnya', style: TextStyle(fontSize: 15)),
      actions: [
        ListenableBuilder(
          listenable: widget.favorites,
          builder: (_, _) => IconButton(
            key: const ValueKey('detail-favorite'),
            tooltip: widget.favorites.contains(widget.id)
                ? 'Hapus dari favorit'
                : 'Simpan ke favorit',
            onPressed: widget.favorites.saving ? null : _save,
            icon: Icon(
              widget.favorites.contains(widget.id)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: FutureBuilder<Cafe>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingPanel());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return SingleChildScrollView(
            child: Center(
              child: FeedbackPanel(
                icon: Icons.cloud_off_rounded,
                title: 'Tempatnya belum bisa dibuka',
                message: '${snapshot.error ?? 'Data tidak tersedia.'}',
                action: _retry,
              ),
            ),
          );
        }
        final cafe = snapshot.data!;
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 740),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: SeduhColors.pale,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        children: [
                          CoffeeArt(size: 150),
                          Text(
                            'Sebuah tempat untuk cerita baru.',
                            style: TextStyle(
                              fontSize: 11,
                              color: SeduhColors.muted,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      '${cafe.area} · ${cafe.category}'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        color: SeduhColors.sage,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(cafe.name, style: editorial(34)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: Color(0xFFA76A24),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cafe.rating?.toStringAsFixed(1) ??
                                  'Belum ada rating',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ' · ${cafe.reviewCount} ulasan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: SeduhColors.muted,
                              ),
                            ),
                          ],
                        ),
                        if (cafe.verified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EBDD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Terverifikasi di sumber',
                              style: TextStyle(
                                fontSize: 10,
                                color: SeduhColors.sage,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    _info(
                      Icons.location_on_outlined,
                      'ALAMAT',
                      cafe.displayAddress,
                    ),
                    _info(
                      Icons.payments_outlined,
                      'KISARAN HARGA',
                      cafe.displayPrice,
                    ),
                    _info(
                      Icons.schedule_rounded,
                      'JAM OPERASIONAL DI SUMBER',
                      cafe.displayHours,
                    ),
                    if (cafe.description.isNotEmpty)
                      _info(
                        Icons.notes_rounded,
                        'TENTANG TEMPAT',
                        cafe.description,
                      ),
                    _info(
                      Icons.wifi_rounded,
                      'FASILITAS',
                      cafe.facilities.isEmpty
                          ? 'Informasi fasilitas belum tersedia'
                          : cafe.facilities.join(' · '),
                    ),
                    if (cafe.tags.isNotEmpty)
                      _info(
                        Icons.sell_outlined,
                        'COCOK UNTUK',
                        cafe.tags.join(' · '),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('open-maps'),
                        onPressed: cafe.mapsUri == null
                            ? null
                            : () => _openMaps(cafe),
                        icon: const Icon(Icons.north_east_rounded, size: 18),
                        label: const Text('Buka di Google Maps'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: cafe.address.isEmpty
                            ? null
                            : () => _copy(cafe),
                        icon: const Icon(Icons.copy_outlined, size: 17),
                        label: const Text('Salin alamat'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SeduhColors.pale,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Informasi mengikuti Surabaya Cafe API. Harga dan jam operasional dapat berubah. '
                        'Cek kembali di Google Maps sebelum berkunjung.'
                        '${cafe.lastVerifiedAt == null ? '' : '\nVerifikasi sumber: ${_date(cafe.lastVerifiedAt!)}.'}',
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.7,
                          color: SeduhColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  Widget _info(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: SeduhColors.coffee),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.1,
                  color: SeduhColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 14, height: 1.6)),
            ],
          ),
        ),
      ],
    ),
  );
  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
