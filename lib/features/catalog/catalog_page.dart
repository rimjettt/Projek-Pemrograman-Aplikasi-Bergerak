import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/book.dart';
import '../../widgets/book_cover.dart';

class CatalogPage extends StatefulWidget {
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
  State<CatalogPage> createState() => _CatalogPageState();
}


class _CatalogPageState extends State<CatalogPage> {
  static const List<String> _categories = [
    'Untuk Anda',
    'Semua buku',
    'Tersedia',
    'Teknologi & Pemrograman',
    'UI/UX Design',
    'Algoritma',
    'Basis Data',
    'Jaringan',
    'Rantai Pasok',
  ];

  String selectedCategory = 'Untuk Anda';
  // Like counts are currently stored in memory for this screen/session.
  final Map<int, int> _likes = {};
  final Set<int> _likedByCurrentUser = {};


  bool _isUiUx(Book book) {
    final value = '${book.category} ${book.title}'.toLowerCase();
    return value.contains('ui/ux') || value.contains('ui ux') || value.contains('design') || value.contains('desain') || value.contains('usability');
  }


  bool _matchesCategory(Book book, String category) {
    final value = '${book.category} ${book.title} ${book.description}'.toLowerCase();
    switch (category) {
      case 'Untuk Anda':
      case 'Semua buku':
        return true;
      case 'Tersedia':
        return book.stock > 0;
      case 'Teknologi & Pemrograman':
      // Keep this category specific to general programming books.
      // Algorithm, database, network, and supply-chain titles have their own tabs.
        return book.category.toLowerCase().trim() == 'pemrograman';
      case 'UI/UX Design':
        return _isUiUx(book);
      case 'Algoritma':
        return value.contains('algoritma');
      case 'Basis Data':
        return value.contains('basis data') || value.contains('database') || value.contains('sql');
      case 'Jaringan':
        return value.contains('jaringan') || value.contains('network') || value.contains('tcp') || value.contains('internet');
      case 'Rantai Pasok':
        return value.contains('rantai pasok') || value.contains('supply chain') || value.contains('logistik');
      default:
        return book.category.toLowerCase() == category.toLowerCase();
    }
  }


  List<Book> get _searchMatchedBooks {
    final keyword = widget.query.trim().toLowerCase();
    return widget.books.where((book) {
      return keyword.isEmpty ||
          book.title.toLowerCase().contains(keyword) ||
          book.author.toLowerCase().contains(keyword) ||
          book.category.toLowerCase().contains(keyword) ||
          book.description.toLowerCase().contains(keyword);
    }).toList();
  }


  List<Book> get _filteredBooks => _searchMatchedBooks
      .where((book) => _matchesCategory(book, selectedCategory))
      .toList();


  List<Book> get _recommendedBooks {
    final matches = _searchMatchedBooks;
    matches.sort((a, b) => (_likes[b.id] ?? 0).compareTo(_likes[a.id] ?? 0));
    return matches;
  }


  void _selectCategory(String category) {
    setState(() => selectedCategory = category);
  }


  void _toggleLike(Book book) {
    setState(() {
      if (_likedByCurrentUser.contains(book.id)) {
        _likedByCurrentUser.remove(book.id);
        _likes[book.id] = ((_likes[book.id] ?? 0) - 1).clamp(0, 999999).toInt();
      } else {
        _likedByCurrentUser.add(book.id);
        _likes[book.id] = (_likes[book.id] ?? 0) + 1;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final hasSearch = widget.query.trim().isNotEmpty;
    final discover = selectedCategory == 'Untuk Anda' && !hasSearch;
    final results = _filteredBooks;

    // Search and category strip remain fixed; only the content area scrolls.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: _buildSearchField(),
        ),
        SizedBox(
          height: 46,
          child: _buildCategoryTabs(),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: discover
                ? _buildShelf(
              title: 'Rekomendasi untuk Anda',
              books: _recommendedBooks,
              onSeeAll: () => _selectCategory('Semua buku'),
            )
                : _buildResults(results, hasSearch),
          ),
        ),
      ],
    );
  }


  Widget _buildSearchField() {
    return TextField(
      controller: widget.searchController,
      onChanged: widget.onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Telusuri judul, penulis, kategori',
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: navy),
        suffixIcon: widget.query.isEmpty
            ? null
            : IconButton(
          tooltip: 'Hapus pencarian',
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.searchController.clear();
            widget.onSearchChanged('');
          },
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: navy, width: 1.4)),
      ),
    );
  }


  Widget _buildCategoryTabs() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final selected = category == selectedCategory;
        return ChoiceChip(
          label: Text(category),
          selected: selected,
          onSelected: (_) => _selectCategory(category),
          showCheckmark: false,
          labelStyle: TextStyle(color: selected ? navy : Colors.grey.shade800, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, fontSize: 13),
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFDDEBDD),
          side: BorderSide(color: selected ? const Color(0xFFDDEBDD) : Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        );
      },
    );
  }


  Widget _buildShelf({required String title, required List<Book> books, required VoidCallback onSeeAll}) {
    if (books.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w700))),
            IconButton(
              onPressed: onSeeAll,
              tooltip: 'Lihat semua',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.arrow_forward, color: navy, size: 20),
              style: IconButton.styleFrom(backgroundColor: const Color(0xFFE8EEE4), shape: const CircleBorder()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 356,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _BookShelfTile(
              book: books[index],
              width: 146,
              liked: _likedByCurrentUser.contains(books[index].id),
              likeCount: _likes[books[index].id] ?? 0,
              onLike: () => _toggleLike(books[index]),
              onTap: () => widget.onSelectBook(books[index]),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildResults(List<Book> books, bool hasSearch) {
    final heading = hasSearch
        ? 'Hasil pencarian'
        : selectedCategory == 'Semua buku'
        ? 'Semua koleksi'
        : selectedCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(heading, style: const TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w700))),
            Text('${books.length} buku', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        if (books.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 42, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('Buku tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w600, color: navy)),
                  const SizedBox(height: 4),
                  Text('Coba kata kunci atau kategori lainnya.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 12) / 2; // Fill both columns evenly; no unused right-side gap.
              return Wrap(
                spacing: 12,
                runSpacing: 20,
                children: books.map((book) => SizedBox(
                  width: tileWidth,
                  child: _BookShelfTile(
                    book: book,
                    width: tileWidth,
                    liked: _likedByCurrentUser.contains(book.id),
                    likeCount: _likes[book.id] ?? 0,
                    onLike: () => _toggleLike(book),
                    onTap: () => widget.onSelectBook(book),
                  ),
                )).toList(),
              );
            },
          ),
      ],
    );
  }
}


class _BookShelfTile extends StatelessWidget {
  final Book book;
  final double width;
  final bool liked;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _BookShelfTile({
    required this.book,
    required this.width,
    required this.liked,
    required this.likeCount,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: BookCover(book: book, width: width, height: width * 1.34),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: Colors.white.withOpacity(0.94),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onLike,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 19, color: liked ? Colors.redAccent : navy),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: navy, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25)),
          const SizedBox(height: 3),
          Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, fontSize: 11.5)),
          const SizedBox(height: 3),
          Text(book.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: accent, fontSize: 11.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(book.stock > 0 ? Icons.check_circle_outline : Icons.cancel_outlined, size: 13, color: book.stock > 0 ? navy : Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(book.stock > 0 ? '${book.stock} tersedia' : 'Stok habis', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: book.stock > 0 ? navy : Colors.grey, fontSize: 11.5, fontWeight: FontWeight.w600))),
              const SizedBox(width: 4),
              Icon(Icons.favorite, size: 12, color: liked ? Colors.redAccent : Colors.grey.shade500),
              const SizedBox(width: 2),
              Text('$likeCount', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
