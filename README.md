# PustakaKu Flutter - Struktur Per Fitur

Aplikasi perpustakaan digital sederhana menggunakan Flutter dan Dart.

## Cara menjalankan

1. Pastikan Flutter SDK sudah terpasang.
2. Buka folder proyek `pustakaku_flutter` di Android Studio atau VS Code.
3. Jalankan `flutter pub get` pada terminal.
4. Jalankan aplikasi dengan `flutter run`.

## Struktur file Dart

```text
lib/
├── main.dart
├── core/
│   ├── app_colors.dart
│   └── date_formatter.dart
├── data/
│   └── book_data.dart
├── models/
│   ├── book.dart
│   ├── loan.dart
│   ├── loan_history.dart
│   └── student_profile.dart
├── features/
│   ├── auth/
│   │   ├── auth_gate.dart
│   │   └── auth_screen.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── catalog/
│   │   ├── catalog_page.dart
│   │   └── book_detail_page.dart
│   ├── loans/
│   │   └── loans_page.dart
│   ├── history/
│   │   └── history_page.dart
│   ├── profile/
│   │   └── profile_page.dart
│   └── library/
│       └── library_home.dart
└── widgets/
    ├── book_card.dart
    └── book_cover.dart
```

## Tugas masing-masing file

- `main.dart`: menjalankan aplikasi dan mengatur tema.
- `features/auth/`: login, registrasi, dan pengecekan sesi.
- `features/home/`: halaman beranda dan pencarian buku.
- `features/catalog/`: katalog dan detail buku.
- `features/loans/`: daftar peminjaman, pembatalan pengajuan, dan pengajuan pengembalian.
- `features/history/`: menampilkan riwayat aktivitas peminjaman, pembatalan, dan pengajuan pengembalian.
- `features/profile/`: melihat serta mengubah profil mahasiswa.
- `features/library/library_home.dart`: mengatur navigasi halaman dan data antarfitur.
- `models/`: bentuk data buku, peminjaman, riwayat, dan profil mahasiswa.
- `data/`: data awal buku.
- `widgets/`: komponen tampilan yang digunakan lebih dari satu fitur.
- `core/`: warna dan fungsi pendukung aplikasi, termasuk format tanggal.

## Alur peminjaman, pengembalian, dan riwayat

1. Saat peminjaman diajukan, pengajuan ditambahkan ke halaman Pinjaman, stok simulasi dikurangi satu, dan aktivitas `Peminjaman Buku` dicatat ke Riwayat dengan status `Menunggu persetujuan`.
2. Saat pengajuan dibatalkan, data peminjaman dihapus dari daftar aktif, stok simulasi dikembalikan, dan aktivitas `Pembatalan Peminjaman` dicatat ke Riwayat dengan status `Dibatalkan`.
3. Saat tombol `Ajukan Pengembalian` dipilih, status pengembalian berubah menjadi `Sedang Diproses`. Tombol aksi diganti dengan informasi bahwa pengembalian menunggu pemeriksaan petugas, lalu aktivitas `Pengajuan Pengembalian` dicatat ke Riwayat.
4. Riwayat ditampilkan dari aktivitas terbaru ke aktivitas sebelumnya.

**Catatan:** sama seperti kode Kotlin sumber, pengajuan pengembalian belum menandakan bahwa buku sudah diterima petugas. Pada tahap ini peminjaman masih berada di daftar Pinjaman dan stok belum ditambahkan kembali. Penyelesaian pengembalian oleh petugas belum menjadi bagian dari alur pada kode sumber.

## Catatan penyimpanan

Data profil disimpan secara lokal menggunakan `shared_preferences`. Data buku, peminjaman, dan riwayat masih berada di memori aplikasi; belum terhubung ke backend atau database online. Data peminjaman dan riwayat akan kembali kosong ketika aplikasi dimulai ulang.
