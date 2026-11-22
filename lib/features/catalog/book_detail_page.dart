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
  final ValueChanged<DateTime> onBorrow;

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
    DateTime selectedDate = DateTime.now();
    final confirmed = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          String formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          return AlertDialog(
            title: const Text('Form Pengajuan Peminjaman', style: TextStyle(fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _readonlyField('Nama peminjam', profile.name.isEmpty ? 'Belum diisi' : profile.name),
                    _readonlyField('Nama buku', book.title),
                    const SizedBox(height: 12),
                    const Text('Tanggal peminjaman', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(formatDate(selectedDate)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setDialogState(() => selectedDate = picked);
                      },
                    ),
                    Text('Tanggal jatuh tempo: ${formatDate(selectedDate.add(const Duration(days: 7)))}'),
                    const SizedBox(height: 12),
                    const Text('Kondisi buku sebelum dipinjam',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Baik', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 12),
                    const Text('Foto kondisi awal buku',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: pale,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.image_outlined, size: 34, color: navy),
                          SizedBox(height: 6),
                          Text('Foto kondisi fisik buku akan ditampilkan di sini.',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Data kondisi awal tidak dapat diubah oleh mahasiswa.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, selectedDate),
                child: const Text('Kirim Pengajuan'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed is DateTime) onBorrow(confirmed);
  }


  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w800)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
