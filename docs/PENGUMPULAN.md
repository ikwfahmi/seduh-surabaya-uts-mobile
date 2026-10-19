# Persiapan pengumpulan UTS

## Berkas

- `README.md`: tujuan, fitur, teknologi, dan langkah menjalankan.
- `docs/Laporan_UTS_Seduh_Surabaya.pdf`: laporan sesuai struktur soal; lengkapi identitas dan logo terlebih dahulu.
- `docs/LAPORAN.md`: naskah laporan yang dapat diedit.
- `docs/identitas.json`: identitas cover; `logo_path` menerima path gambar logo fakultas.
- `docs/screenshots/`: screenshot asli aplikasi Flutter web pada ukuran ponsel/desktop.
- `docs/pengujian-otomatis.txt`, `docs/analisis-statis.txt`, dan `docs/live-api-check.json`: bukti verifikasi.
- APK ARM64 disediakan terpisah untuk pemasangan pada mayoritas Android modern.

## Sebelum dikumpulkan

1. Isi nama, NIM, kelas, jurusan, fakultas, kampus dan logo. Jangan mengumpulkan cover yang masih berisi penanda `[ ... ]`.
2. Baca laporan dan pahami implementasi, khususnya JSON model, async/await, dan FutureBuilder.
3. Jalankan APK pada ponsel/emulator Android sendiri; uji internet aktif/nonaktif, pencarian, detail, favorit setelah restart, dan Google Maps.
4. Tambahkan hasil pengujian perangkat tersebut pada laporan jika diperlukan. Pengujian runtime Android fisik belum dilakukan dalam pengerjaan ini.
5. Unggah source code lengkap ke repositori GitHub public. Pastikan `pubspec.lock`, folder `android`, folder `web`, font, dan test ikut terunggah; cache build dan file rahasia tidak ikut.
6. Unggah PDF yang identitasnya sudah lengkap ke Google Drive. Pilih **General access → Anyone with the link → Viewer**.
7. Buka kedua tautan menggunakan jendela Incognito tanpa login. Periksa repositori dan PDF dapat diakses tanpa permintaan izin.
8. Kumpulkan tautan GitHub serta tautan PDF Google Drive sesuai mekanisme dosen.

## Tenggat pada soal

- Versi **Praktikum Mobile Programming H**: Senin, **26 Oktober 2026 pukul 23.59 WIB**.
- Versi **kelas C**: Jumat, **23 Oktober 2026 pukul 23.59 WIB**.

Gunakan tenggat sesuai kelas Anda; kedua PDF memiliki ketentuan teknis dan penilaian yang sama.
