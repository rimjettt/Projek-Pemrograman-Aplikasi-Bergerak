import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/book.dart';
import '../../models/student_profile.dart';
import '../../widgets/book_card.dart';

class HomePage extends StatelessWidget {
  final StudentProfile profile;
  final List<Book> books;
  final int loanCount;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenCatalog;
  final ValueChanged<Book> onSelectBook;

  const HomePage({
    super.key,
    required this.profile,
    required this.books,
    required this.loanCount,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onOpenCatalog,
    required this.onSelectBook,
  });

  @override
  Widget build(BuildContext context) {
    final results = _filterBooks(books, searchQuery);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Halo, ${profile.name.trim().isEmpty ? "Mahasiswa" : profile.name}! 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Cari judul, penulis, kategori',
          ),
        ),
        const SizedBox(height: 16),
        if (searchQuery.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Baca. Belajar. Bertumbuh.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cari buku yang ingin kamu pinjam.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: navy,
                  ),
                  onPressed: onOpenCatalog,
                  child: const Text('Jelajahi Katalog'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCard('Koleksi buku', books.length.toString()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('Pengajuan saya', loanCount.toString()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Rekomendasi buku',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 10),
          ...books.take(3).map(
            (book) => BookCard(
              book: book,
              onTap: () => onSelectBook(book),
            ),
          ),
        ] else ...[
          Text(
            'Hasil pencarian • ${results.length} buku ditemukan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          if (results.isEmpty) const Text('Buku tidak ditemukan.'),
          ...results.map(
            (book) => BookCard(
              book: book,
              onTap: () => onSelectBook(book),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Book> _filterBooks(List<Book> source, String query) {
    final keyword = query.toLowerCase();
    return source.where((book) {
      return book.title.toLowerCase().contains(keyword) ||
          book.author.toLowerCase().contains(keyword) ||
          book.category.toLowerCase().contains(keyword);
    }).toList();
  }
}
