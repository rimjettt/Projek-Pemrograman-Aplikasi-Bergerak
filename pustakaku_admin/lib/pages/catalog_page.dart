import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_frame.dart';
import '../widgets/admin_section_card.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/labeled_form_fields.dart';
import '../widgets/status_badge.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  static const List<String> _categories = [
    'Semua kategori',
    'Novel',
    'Pengembangan Diri',
    'Pendidikan',
    'Sejarah',
    'Sains',
  ];

  final TextEditingController _searchController = TextEditingController();
  final List<_BookRecord> _books = [
    const _BookRecord(
      title: 'Laut Bercerita',
      author: 'Leila S. Chudori',
      category: 'Novel',
      stock: 12,
      condition: 'Baik',
    ),
    const _BookRecord(
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      category: 'Sejarah',
      stock: 8,
      condition: 'Baik',
    ),
    const _BookRecord(
      title: 'Filosofi Teras',
      author: 'Henry Manampiring',
      category: 'Pengembangan Diri',
      stock: 5,
      condition: 'Rusak Ringan',
    ),
    const _BookRecord(
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Pengembangan Diri',
      stock: 9,
      condition: 'Baik',
    ),
    const _BookRecord(
      title: 'Fisika Dasar',
      author: 'Halliday, Resnick, Walker',
      category: 'Pendidikan',
      stock: 0,
      condition: 'Perlu Perbaikan',
    ),
  ];

  String _selectedCategory = _categories.first;

  List<_BookRecord> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();
    return _books.where((book) {
      final matchesQuery =
          query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == _categories.first ||
          book.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> _openBookForm({int? index}) async {
    final book = index == null ? null : _books[index];
    final result = await showDialog<_BookRecord>(
      context: context,
      builder: (context) => _BookFormDialog(book: book),
    );
    if (result == null || !mounted) {
      return;
    }

    setState(() {
      if (index == null) {
        _books.insert(0, result);
      } else {
        _books[index] = result;
      }
    });
  }

  Future<void> _deleteBook(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Hapus "${_books[index].title}" dari katalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9A4438),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _books.removeAt(index);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminPageFrame(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdminPageHeader(
                title: 'Katalog Buku',
                subtitle: 'Kelola koleksi, ketersediaan, dan kondisi buku perpustakaan.',
              ),
              const SizedBox(height: 20),
              _buildToolbar(constraints.maxWidth),
              const SizedBox(height: 20),
              AdminSectionCard(
                title: 'Daftar Buku',
                subtitle: '${_filteredBooks.length} buku ditampilkan',
                child: _buildBookTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(double width) {
    final searchField = TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        labelText: 'Cari buku atau penulis',
        prefixIcon: Icon(Icons.search),
      ),
    );
    final categoryFilter = FilterDropdown(
      hint: 'Kategori',
      value: _selectedCategory,
      options: _categories,
      prefixIcon: Icons.category_outlined,
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
    final addButton = FilledButton.icon(
      onPressed: _openBookForm,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Buku'),
    );

    if (width >= 740) {
      return Row(
        children: [
          Expanded(child: searchField),
          const SizedBox(width: 12),
          SizedBox(width: 220, child: categoryFilter),
          const SizedBox(width: 12),
          addButton,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchField,
        const SizedBox(height: 12),
        categoryFilter,
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: addButton),
      ],
    );
  }

  Widget _buildBookTable() {
    if (_filteredBooks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Tidak ada buku yang sesuai dengan filter.')),
      );
    }

    return AdminDataTable(
      minWidth: 1040,
      rowHeight: 64,
      columnSpacing: 14,
      columns: const [
        DataColumn(label: AdminTableHeading('JUDUL', width: 140)),
        DataColumn(label: AdminTableHeading('PENULIS', width: 160)),
        DataColumn(label: AdminTableHeading('KATEGORI', width: 140)),
        DataColumn(label: AdminTableHeading('STOK', width: 60)),
        DataColumn(label: AdminTableHeading('KONDISI', width: 140)),
        DataColumn(label: AdminTableHeading('AKSI', width: 100)),
      ],
      rows: _filteredBooks.map((book) {
        final index = _books.indexOf(book);
        return DataRow(
          cells: [
            DataCell(
              Text(
                book.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(Text(book.author)),
            DataCell(Text(book.category)),
            DataCell(Text('${book.stock}')),
            DataCell(StatusBadge(label: book.condition)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit buku',
                    onPressed: () => _openBookForm(index: index),
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.navy,
                  ),
                  IconButton(
                    tooltip: 'Hapus buku',
                    onPressed: () => _deleteBook(index),
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFF9A4438),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _BookRecord {
  const _BookRecord({
    required this.title,
    required this.author,
    required this.category,
    required this.stock,
    required this.condition,
  });

  final String title;
  final String author;
  final String category;
  final int stock;
  final String condition;
}

class _BookFormDialog extends StatefulWidget {
  const _BookFormDialog({this.book});

  final _BookRecord? book;

  @override
  State<_BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<_BookFormDialog> {
  static const List<String> _categories = [
    'Novel',
    'Pengembangan Diri',
    'Pendidikan',
    'Sejarah',
    'Sains',
  ];
  static const List<String> _conditions = [
    'Baik',
    'Rusak Ringan',
    'Perlu Perbaikan',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _stockController;
  late String _category;
  late String _condition;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _stockController = TextEditingController(
      text: book == null ? '' : '${book.stock}',
    );
    _category = book?.category ?? _categories.first;
    _condition = book?.condition ?? _conditions.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(
      context,
      _BookRecord(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _category,
        stock: int.parse(_stockController.text.trim()),
        condition: _condition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width - 64;
    return AlertDialog(
      title: Text(widget.book == null ? 'Tambah Buku' : 'Edit Buku'),
      content: SizedBox(
        width: dialogWidth.clamp(0, 560),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final categoryField = LabeledDropdownFormField<String>(
                  label: 'Kategori',
                  value: _category,
                  hintText: 'Pilih kategori buku',
                  items: [
                    for (final category in _categories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                );
                final conditionField = LabeledDropdownFormField<String>(
                  label: 'Kondisi Buku',
                  value: _condition,
                  hintText: 'Pilih kondisi buku',
                  items: [
                    for (final condition in _conditions)
                      DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _condition = value);
                    }
                  },
                );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledTextFormField(
                      label: 'Judul Buku',
                      controller: _titleController,
                      hintText: 'Masukkan judul buku',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    LabeledTextFormField(
                      label: 'Penulis',
                      controller: _authorController,
                      hintText: 'Masukkan nama penulis',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    if (constraints.maxWidth >= 460)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: categoryField),
                          const SizedBox(width: 16),
                          Expanded(child: conditionField),
                        ],
                      )
                    else ...[
                      categoryField,
                      const SizedBox(height: 16),
                      conditionField,
                    ],
                    const SizedBox(height: 16),
                    LabeledTextFormField(
                      label: 'Stok Buku',
                      controller: _stockController,
                      hintText: 'Masukkan jumlah stok',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final stock = int.tryParse(value?.trim() ?? '');
                        if (stock == null || stock < 0) {
                          return 'Masukkan stok berupa angka nol atau lebih.';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan Buku')),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    return null;
  }
}
