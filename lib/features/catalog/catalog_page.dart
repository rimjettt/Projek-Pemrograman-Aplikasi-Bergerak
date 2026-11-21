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
  static const double _maxContentWidth = 1240;

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
  final Map<int, int> _likes = {};
  final Set<int> _likedByCurrentUser = {};

  bool _isUiUx(Book book) {
    final value = '${book.category} ${book.title}'.toLowerCase();
    return value.contains('ui/ux') ||
        value.contains('ui ux') ||
        value.contains('design') ||
        value.contains('desain') ||
        value.contains('usability');
  }

  bool _matchesCategory(Book book, String category) {
    final value =
    '${book.category} ${book.title} ${book.description}'.toLowerCase();

    switch (category) {
      case 'Untuk Anda':
      case 'Semua buku':
        return true;
      case 'Tersedia':
        return book.stock > 0;
      case 'Teknologi & Pemrograman':
        return book.category.toLowerCase().trim() == 'pemrograman';
      case 'UI/UX Design':
        return _isUiUx(book);
      case 'Algoritma':
        return value.contains('algoritma');
      case 'Basis Data':
        return value.contains('basis data') ||
            value.contains('database') ||
            value.contains('sql');
      case 'Jaringan':
        return value.contains('jaringan') ||
            value.contains('network') ||
            value.contains('tcp') ||
            value.contains('internet');
      case 'Rantai Pasok':
        return value.contains('rantai pasok') ||
            value.contains('supply chain') ||
            value.contains('logistik');
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
    final matches = List<Book>.from(_searchMatchedBooks);
    matches.sort(
          (a, b) => (_likes[b.id] ?? 0).compareTo(_likes[a.id] ?? 0),
    );
    return matches;
  }

  void _selectCategory(String category) {
    setState(() => selectedCategory = category);
  }

  void _toggleLike(Book book) {
    setState(() {
      if (_likedByCurrentUser.contains(book.id)) {
        _likedByCurrentUser.remove(book.id);
        _likes[book.id] =
            ((_likes[book.id] ?? 0) - 1).clamp(0, 999999).toInt();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildSearchField(),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: _buildCategoryTabs(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _maxContentWidth,
                ),
                child: discover
                    ? _buildShelf(
                  title: 'Rekomendasi untuk Anda',
                  books: _recommendedBooks,
                  onSeeAll: () => _selectCategory('Semua buku'),
                )
                    : _buildResults(results, hasSearch),
              ),
            ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: navy, width: 1.4),
        ),
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
          labelStyle: TextStyle(
            color: selected ? navy : Colors.grey.shade800,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFDDEBDD),
          side: BorderSide(
            color: selected
                ? const Color(0xFFDDEBDD)
                : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        );
      },
    );
  }

  Widget _buildShelf({
    required String title,
    required List<Book> books,
    required VoidCallback onSeeAll,
  }) {
    if (books.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Kartu rekomendasi dibatasi agar tidak membesar berlebihan di laptop.
        final tileWidth =
        (constraints.maxWidth * 0.23).clamp(150.0, 190.0).toDouble();
        final tileHeight = tileWidth * 1.34 + 112;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onSeeAll,
                  tooltip: 'Lihat semua',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_forward, color: navy, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EEE4),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: tileHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _BookShelfTile(
                    book: book,
                    width: tileWidth,
                    liked: _likedByCurrentUser.contains(book.id),
                    likeCount: _likes[book.id] ?? 0,
                    onLike: () => _toggleLike(book),
                    onTap: () => widget.onSelectBook(book),
                  );
                },
              ),
            ),
          ],
        );
      },
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
            Expanded(
              child: Text(
                heading,
                style: const TextStyle(
                  color: navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${books.length} buku',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 42, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text(
                    'Buku tidak ditemukan',
                    style: TextStyle(fontWeight: FontWeight.w600, color: navy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coba kata kunci atau kategori lainnya.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              // Lebar kartu dijaga tetap proporsional pada setiap ukuran layar.
              final crossAxisCount =
              (constraints.maxWidth / 190).floor().clamp(2, 5).toInt();
              const spacing = 16.0;
              final tileWidth = (constraints.maxWidth -
                  (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: 24,
                children: books.map((book) {
                  return SizedBox(
                    width: tileWidth,
                    child: _BookShelfTile(
                      book: book,
                      width: tileWidth,
                      liked: _likedByCurrentUser.contains(book.id),
                      likeCount: _likes[book.id] ?? 0,
                      onLike: () => _toggleLike(book),
                      onTap: () => widget.onSelectBook(book),
                    ),
                  );
                }).toList(),
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
    final compact = width < 165;
    final titleFontSize = compact ? 12.5 : 14.0;
    final detailFontSize = compact ? 10.5 : 11.5;
    final coverHeight = width * 1.34;

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
                child: BookCover(
                  book: book,
                  width: width,
                  height: coverHeight,
                ),
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
                      padding: EdgeInsets.all(compact ? 6 : 7),
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        size: compact ? 17 : 19,
                        color: liked ? Colors.redAccent : navy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: navy,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: detailFontSize,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            book.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: accent, fontSize: detailFontSize),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                book.stock > 0
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: 13,
                color: book.stock > 0 ? navy : Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  book.stock > 0 ? '${book.stock} tersedia' : 'Stok habis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: book.stock > 0 ? navy : Colors.grey,
                    fontSize: detailFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.favorite,
                size: 12,
                color: liked ? Colors.redAccent : Colors.grey.shade500,
              ),
              const SizedBox(width: 2),
              Text(
                '$likeCount',
                style: TextStyle(
                  fontSize: detailFontSize,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
