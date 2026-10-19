import 'package:flutter/material.dart';

import '../models/cafe.dart';
import '../theme.dart';

class CafeCard extends StatelessWidget {
  const CafeCard({
    super.key,
    required this.cafe,
    required this.favorite,
    required this.onOpen,
    required this.onFavorite,
    this.saving = false,
  });
  final Cafe cafe;
  final bool favorite, saving;
  final VoidCallback onOpen, onFavorite;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: SeduhColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            key: ValueKey('open-${cafe.id}'),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: _color(cafe.area),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_cafe_outlined,
                          color: SeduhColors.coffee,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFFA76A24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cafe.rating?.toStringAsFixed(1) ?? '—',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${cafe.reviewCount})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: SeduhColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Text(
                    cafe.area.isEmpty ? 'Surabaya' : cafe.area.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: SeduhColors.sage,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cafe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: editorial(22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cafe.displayAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SeduhColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 3, 8, 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cafe.displayPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                key: ValueKey('favorite-${cafe.id}'),
                tooltip: favorite
                    ? 'Hapus ${cafe.name} dari favorit'
                    : 'Simpan ${cafe.name} ke favorit',
                onPressed: saving ? null : onFavorite,
                icon: Icon(
                  favorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 21,
                  color: favorite ? SeduhColors.coffee : SeduhColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  static Color _color(String area) => switch (area) {
    'Surabaya Barat' => const Color(0xFFF2E8D9),
    'Surabaya Timur' => const Color(0xFFE7EBDE),
    'Surabaya Pusat' => const Color(0xFFF3E2D9),
    'Surabaya Selatan' => const Color(0xFFE3EAE7),
    _ => const Color(0xFFEBE5F0),
  };
}
