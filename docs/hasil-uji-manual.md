# Catatan verifikasi aplikasi

Tanggal: 19 Oktober 2026. Aplikasi Flutter web release di localhost, viewport desktop dan ponsel 390 × 844. Data diambil langsung dari API, bukan data contoh bawaan aplikasi.

| Skenario | Hasil |
| --- | --- |
| Memuat daftar dari API | Berhasil: 874 entri, lima wilayah pada waktu pengecekan |
| Mengetik `boncafe` | Berhasil: tiga hasil dari keseluruhan dataset |
| Memilih filter Barat tanpa kata kunci | Berhasil: 330 entri |
| Menyimpan Boncafe - Manyar Kertoarjo | Berhasil: ikon berubah dan notifikasi favorit tersimpan |
| Membuka detail kafe | Berhasil: nama, rating, ulasan, alamat, harga, jam, dan fasilitas ditampilkan dari endpoint detail |
| Navigasi kembali | Berhasil: daftar dan kata kunci tetap tersedia |
| Google Maps | URL detail valid; membuka aplikasi Maps eksternal pada Android masih perlu uji perangkat |
| Salin alamat | Implementasi tersedia; verifikasi clipboard sistem pada Android masih perlu uji perangkat |

31 tes unit/widget lulus. `flutter analyze` melaporkan tidak ada masalah. APK ARM64 release dan build web berhasil. Pengujian error, timeout, data kosong, fallback field, filter gabungan dan pemulihan retry dilakukan secara deterministik dengan MockClient. Tidak ada klaim uji runtime pada perangkat Android fisik.
