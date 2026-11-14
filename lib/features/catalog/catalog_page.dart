import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/book.dart';
import '../../widgets/book_card.dart';

class CatalogPage extends StatelessWidget {
  final List<Book> books;
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Book> onSelectBook;

  const CatalogPage({
    super.key,
    required this.books,
    required this.query,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSelectBook,
  });

  @override
  Widget build(BuildContext context) {
    final results = _filterBooks(books, query);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Katalog Buku',
          style: TextStyle(
            fontSize: 25,
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
        const SizedBox(height: 12),
        Text(
          '${results.length} buku ditemukan',
          style: const TextStyle(color: Colors.grey),
        ),
        if (results.isEmpty) const Text('Buku tidak ditemukan.'),
        ...results.map(
          (book) => Column(
            children: [
              BookCard(
                book: book,
                onTap: () => onSelectBook(book),
              ),
              OutlinedButton.icon(
                onPressed: () => onSelectBook(book),
                icon: const Icon(Icons.info_outline),
                label: const Text('Lihat detail buku'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  List<Book> _filterBooks(List<Book> source, String value) {
    final keyword = value.toLowerCase();
    return source.where((book) {
      return book.title.toLowerCase().contains(keyword) ||
          book.author.toLowerCase().contains(keyword) ||
          book.category.toLowerCase().contains(keyword);
    }).toList();
  }
}
