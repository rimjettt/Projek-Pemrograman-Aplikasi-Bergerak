import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/book.dart';
import '../../models/student_profile.dart';
import '../../widgets/book_cover.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;
  final StudentProfile profile;
  final bool alreadyApplied;
  final VoidCallback onBack;
  final VoidCallback onBorrow;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.profile,
    required this.alreadyApplied,
    required this.onBack,
    required this.onBorrow,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali'),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
          ),
        ),
        const Text(
          'Detail Buku',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: BookCover(
                    book: book,
                    width: 180,
                    height: 240,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 12),
                _detailLine('Penulis', book.author),
                _detailLine('Kategori', book.category),
                _detailLine('Tahun terbit', book.year),
                _detailLine('Penerbit', book.publisher),
                _detailLine('ISBN', book.isbn),
                _detailLine('Stok tersedia', book.stock.toString()),
                _detailLine(
                  'Ketersediaan',
                  book.stock > 0 ? 'Tersedia' : 'Tidak tersedia',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Deskripsi singkat',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(book.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: pale,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketentuan Peminjaman',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '• Masa peminjaman 7 hari.\n'
                  '• Pengajuan menunggu persetujuan petugas.\n'
                  '• Buku diambil secara langsung di perpustakaan.\n'
                  '• Jatuh tempo dihitung setelah buku diserahkan petugas.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: book.stock > 0 && !alreadyApplied
                ? () => _confirmBorrow(context)
                : null,
            child: Text(
              alreadyApplied
                  ? 'Sudah diajukan'
                  : book.stock < 1
                      ? 'Stok habis'
                      : 'Ajukan Peminjaman',
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }

  Future<void> _confirmBorrow(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Peminjaman'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buku: ${book.title}'),
              Text(
                'Nama: ${profile.name.isEmpty ? "Belum diisi" : profile.name}',
              ),
              Text(
                'NIM: ${profile.nim.isEmpty ? "Belum diisi" : profile.nim}',
              ),
              const Text('Masa peminjaman: 7 hari'),
              const SizedBox(height: 8),
              const Text(
                'Pengajuan disimpan di aplikasi dan menunggu persetujuan '
                'petugas. Buku diambil langsung setelah disetujui.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Kirim Pengajuan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onBorrow();
    }
  }
}
