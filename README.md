# Seduh Surabaya

Aplikasi Flutter untuk menemukan kafe dan tempat makan di Surabaya menggunakan data langsung dari [Surabaya Cafe API](https://surabaya-cafe-api.vercel.app/). Dibuat untuk UTS Pemrograman Mobile dengan Dart, HTTP, class model, dan `FutureBuilder`.

## Fitur

- Daftar dinamis dari API, disertai rating, jumlah ulasan, alamat, dan kisaran harga.
- Pencarian nama, alamat, kategori, dan wilayah tanpa membedakan huruf besar/kecil.
- Filter lima wilayah dan pengurutan berdasarkan jumlah ulasan, rating, atau nama.
- Detail kafe dari endpoint berdasarkan ID, termasuk jam operasional, fasilitas, dan tanggal verifikasi sumber.
- Favorit persisten pada perangkat/browser menggunakan `shared_preferences`.
- Buka lokasi di Google Maps dan salin alamat.
- Loading, sukses, error dengan retry, respons kosong, dan hasil pencarian kosong.
- Muat ulang lewat ikon refresh atau tarik layar ke bawah.
- Tampilan responsif untuk ponsel dan desktop, font lokal, navigasi keyboard, dan semantics.

## Teknologi

Diuji dengan Flutter **3.47.7** dan Dart **3.13.5**. Versi dependensi tepat dicatat pada `pubspec.lock`.

| Package | Peran |
| --- | --- |
| `http` | Permintaan GET HTTPS; status respons, UTF-8, JSON, dan timeout |
| `shared_preferences` | Penyimpanan ID favorit lokal |
| `url_launcher` | Membuka tautan Google Maps pada aplikasi/browser eksternal |
| `flutter_test` | Pengujian unit dan widget; `MockClient` tersedia dari `http/testing.dart` |
| `flutter_lints` | Analisis statis |

Tidak memerlukan API key, akun, atau backend tambahan. Font DM Sans dan Fraunces dibundel lokal dengan lisensi SIL OFL pada `assets/fonts/`. Ilustrasi cangkir digambar dengan `CustomPainter`; bukan foto tempat.

## Menjalankan aplikasi

1. Pasang [Flutter SDK](https://docs.flutter.dev/get-started/install), Android SDK, dan JDK 17 atau versi JDK yang kompatibel dengan Gradle proyek.
2. Aktifkan USB debugging pada ponsel Android atau jalankan emulator. Untuk web gunakan Chrome.
3. Jalankan dari direktori proyek:

```bash
flutter pub get
flutter devices
flutter run
```

Pilih perangkat yang tersedia, atau tentukan ID:

```bash
flutter run -d chrome
flutter run -d <id-perangkat-android>
```

Aplikasi membutuhkan koneksi internet saat memuat daftar dan detail. AndroidManifest sudah menyertakan permission `INTERNET` untuk build release.

## Pengujian dan build

```bash
flutter analyze
flutter test --reporter expanded
# Pengecekan API sesungguhnya, terpisah dari tes deterministik:
dart run tool/check_live_api.dart
# APK universal (lebih besar):
flutter build apk --release
# APK untuk mayoritas ponsel Android modern (ARM64):
flutter build apk --release --target-platform android-arm64
# Versi web:
flutter build web --release
```

Hasil APK berada di `build/app/outputs/flutter-apk/app-release.apk`. APK yang disediakan adalah build tugas dengan debug signing, untuk instalasi/pengujian langsung; distribusi Play Store memerlukan konfigurasi signing sendiri. Build Android telah diverifikasi, tetapi uji runtime Android pada perangkat fisik belum dilakukan di lingkungan pengerjaan ini. Screenshot laporan berasal dari aplikasi Flutter web pada viewport ponsel, bukan emulator Android.

Build web dapat disajikan dengan server HTTP, bukan membuka `index.html` lewat `file://`:

```bash
python3 -m http.server 8080 --directory build/web
```

Lalu buka `http://localhost:8080`. Saat pertama dibuka, Flutter web dapat mengunduh mesin rendering dari CDN Flutter.

## Struktur proyek

```text
lib/
  main.dart                    # Inisialisasi Flutter dan penyimpanan lokal
  app.dart                     # MaterialApp dan tema
  theme.dart                   # Palet, tipografi, tema komponen
  models/cafe.dart             # Konversi JSON dan fallback data opsional
  models/cafe_filter.dart      # Pencarian, filter, dan pengurutan lokal
  services/cafe_api.dart       # HTTP, pagination, timeout, error, detail
  state/favorites_store.dart   # ChangeNotifier dan persistensi favorit
  screens/explore_screen.dart  # FutureBuilder daftar, pencarian, favorit
  screens/detail_screen.dart   # FutureBuilder detail, Maps, clipboard
  widgets/                     # Kartu, ilustrasi, loading/error/empty state
test/                          # Tes unit dan widget, fixture respons API
tool/check_live_api.dart        # Pengecekan API sungguhan
docs/                          # Laporan, tangkapan layar, bukti pengujian
```

## API dan alur data

Endpoint utama: `GET https://surabaya-cafe-api.vercel.app/api/cafes?limit=1000&page=1`. Jika API mengembalikan lebih dari satu halaman, service mengambil halaman berikutnya hingga lengkap (maksimum 100 halaman sebagai batas defensif). Detail: `GET /api/cafes/{id}`.

`HTTP → status 200 → JSON UTF-8 → class Cafe → FutureBuilder → GUI`.

Future dibuat dalam `initState`, disimpan di state, dan hanya diganti saat refresh/retry. Mengubah kata kunci atau favorit tidak mengirim ulang HTTP. Pencarian, filter, dan pengurutan bekerja pada keseluruhan data yang sudah diambil, bukan hanya 24 kartu pertama. Tombol “Tampilkan lagi” menambah jumlah kartu yang dirender sebanyak 24.

API memuat kafe serta beberapa restoran/tempat makan. Aplikasi mempertahankan kategori dari sumber. Kolom kosong ditampilkan sebagai “belum tersedia”; tidak ada harga, foto, fasilitas, atau jam buka rekaan. `opening_hours` merupakan teks snapshot dari sumber, bukan perhitungan status buka saat ini. Periksa Google Maps sebelum berkunjung.

Favorit menyimpan ID, bukan salinan isi API. Daftar favorit tetap membutuhkan API untuk menampilkan data. Jika data kafe dihapus dari API, ID favorit lama tidak menghasilkan kartu. Kegagalan penyimpanan tidak dianggap berhasil.

## Laporan dan pengumpulan

Lihat `docs/LAPORAN.md` untuk naskah yang dapat diedit dan `docs/Laporan_UTS_Seduh_Surabaya.pdf` untuk hasil PDF. Cover masih memiliki kolom nama, NIM, jurusan, fakultas, kampus, kelas, serta tempat logo yang perlu diisi sebelum pengumpulan. Kelas tidak diasumsikan karena dua dokumen soal memiliki kelas berbeda.

Daftar persyaratan dan langkah pengumpulan ada di `docs/PENGUMPULAN.md`. Laporan disusun mengikuti BAB I, BAB II, BAB III dan daftar pustaka pada soal UTS.

## Sumber

- [Surabaya Cafe API](https://surabaya-cafe-api.vercel.app/) — Reyhandhani; lisensi data menurut dokumentasi API: MIT.
- [Flutter: Fetch data from the internet](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Flutter: FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [Dart: Asynchronous programming](https://dart.dev/libraries/async/async-await)
- [http](https://pub.dev/packages/http), [shared_preferences](https://pub.dev/packages/shared_preferences), [url_launcher](https://pub.dev/packages/url_launcher)

## Unduhan dan tautan pengumpulan

- Repositori public: https://github.com/ikwfahmi/seduh-surabaya-uts-mobile
- APK dan PDF: https://github.com/ikwfahmi/seduh-surabaya-uts-mobile/releases/tag/v1.0.0
- Draf PDF Google Drive: https://drive.google.com/file/d/1OFxDeqYZ5yecXX7GNyYAwAI_E8CtY4f-/view?usp=drivesdk

Akses Google Drive saat diunggah masih terbatas pada pemilik. Sebelum pengumpulan, lengkapi cover, ganti isi PDF, lalu atur **Anyone with the link → Viewer** dan uji tanpa login. Repositori GitHub sudah public.

Untuk membangun ulang PDF setelah mengisi `docs/identitas.json` atau mengedit `docs/LAPORAN.md`:

```bash
python3 -m pip install reportlab pillow
python3 tool/build_report.py
```

Generator menggunakan font Liberation dari `/usr/share/fonts/liberation`; sesuaikan `FONT_DIR` pada skrip jika lokasi font berbeda. Hasil PDF ditulis ke `docs/Laporan_UTS_Seduh_Surabaya.pdf`.
