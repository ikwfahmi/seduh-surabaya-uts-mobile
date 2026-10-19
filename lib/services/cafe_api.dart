import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cafe.dart';

class CafeApiException implements Exception {
  const CafeApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CafeApi {
  CafeApi({http.Client? client, this.timeout = const Duration(seconds: 20)})
    : _client = client ?? http.Client();
  final http.Client _client;
  final Duration timeout;
  static const baseUrl = 'https://surabaya-cafe-api.vercel.app';

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw CafeApiException(
          response.statusCode == 404
              ? 'Kafe tidak ditemukan. Data mungkin sudah diperbarui.'
              : 'Server sedang bermasalah (HTTP ${response.statusCode}). Coba lagi.',
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const CafeApiException(
        'Koneksi terlalu lama. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const CafeApiException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const CafeApiException(
        'Format data dari server tidak dapat dibaca.',
      );
    }
  }

  /// Fetch every page so local filtering uses the complete dataset.
  Future<List<Cafe>> fetchCafes() async {
    final result = <Cafe>[];
    var page = 1;
    var totalPages = 1;
    do {
      final json = await _get('/api/cafes', {'limit': '1000', 'page': '$page'});
      if (json is! Map<String, dynamic> ||
          json['success'] != true ||
          json['data'] is! List) {
        throw const CafeApiException(
          'Struktur daftar kafe dari server tidak valid.',
        );
      }
      try {
        for (final row in json['data'] as List) {
          if (row is! Map<String, dynamic>) throw const FormatException();
          result.add(Cafe.fromJson(row));
        }
      } on FormatException {
        throw const CafeApiException(
          'Data kafe dari server tidak lengkap atau rusak.',
        );
      }
      totalPages = int.tryParse('${json['total_pages']}') ?? 1;
      if (totalPages < 1 || totalPages > 100) {
        throw const CafeApiException(
          'Informasi halaman dari server tidak valid.',
        );
      }
      page++;
    } while (page <= totalPages);
    return result;
  }

  Future<Cafe> fetchCafe(int id) async {
    final json = await _get('/api/cafes/$id');
    if (json is! Map<String, dynamic>) {
      throw const CafeApiException('Struktur detail kafe tidak valid.');
    }
    try {
      final cafe = Cafe.fromJson(json);
      if (cafe.id != id) throw const FormatException();
      return cafe;
    } on FormatException {
      throw const CafeApiException('Data detail kafe tidak valid.');
    }
  }

  void close() => _client.close();
}
