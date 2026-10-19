/// Typed representation of an item from Surabaya Cafe API.
class Cafe {
  const Cafe({
    required this.id,
    required this.name,
    required this.area,
    this.category = '',
    this.address = '',
    this.priceRange = '',
    this.openingHours = '',
    this.description = '',
    this.rating,
    this.reviewCount = 0,
    this.latitude,
    this.longitude,
    this.mapsUrl = '',
    this.verified = false,
    this.lastVerifiedAt,
    this.facilities = const [],
    this.tags = const [],
  });
  final int id;
  final String name, area, category, address, priceRange;
  final String openingHours, description, mapsUrl;
  final double? rating, latitude, longitude;
  final int reviewCount;
  final bool verified;
  final DateTime? lastVerifiedAt;
  final List<String> facilities, tags;

  factory Cafe.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    final name = _text(json['name']);
    if (id == null || name.isEmpty) {
      throw const FormatException('Identitas kafe tidak valid.');
    }
    final rating = _number(json['gmaps_rating']);
    return Cafe(
      id: id,
      name: name,
      area: _text(json['area']),
      category: _text(json['category']),
      address: _text(json['address']),
      priceRange: _text(json['price_range']),
      openingHours: _text(json['opening_hours']),
      description: _text(json['description']),
      rating: rating != null && rating > 0 && rating <= 5 ? rating : null,
      reviewCount: int.tryParse('${json['gmaps_review_count']}') ?? 0,
      latitude: _number(json['latitude']),
      longitude: _number(json['longitude']),
      mapsUrl: _text(json['gmaps_url']),
      verified: json['verified'] == true,
      lastVerifiedAt: DateTime.tryParse(_text(json['last_verified_at'])),
      facilities: _strings(json['facilities']),
      tags: _strings(json['needs_tags']),
    );
  }
  static String _text(dynamic value) => value is String ? value.trim() : '';
  static double? _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value');
  static List<String> _strings(dynamic value) => value is List
      ? value.whereType<String>().where((v) => v.trim().isNotEmpty).toList()
      : [];
  String get displayAddress =>
      address.isEmpty ? 'Alamat belum tersedia' : address;
  String get displayPrice =>
      priceRange.isEmpty ? 'Harga belum tersedia' : priceRange;
  String get displayHours =>
      openingHours.isEmpty ? 'Jam operasional belum tersedia' : openingHours;

  /// Accept only HTTPS Google Maps links, never arbitrary API schemes.
  Uri? get mapsUri {
    final uri = Uri.tryParse(mapsUrl);
    if (uri != null &&
        uri.scheme == 'https' &&
        (uri.host == 'www.google.com' || uri.host == 'google.com') &&
        uri.path.startsWith('/maps')) {
      return uri;
    }
    if (latitude != null &&
        longitude != null &&
        latitude!.abs() <= 90 &&
        longitude!.abs() <= 180) {
      return Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$latitude,$longitude',
      });
    }
    return null;
  }
}
