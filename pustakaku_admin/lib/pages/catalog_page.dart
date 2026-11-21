import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // Data demo lokal. Belum terhubung ke database.
  // Field mengikuti model Book pada aplikasi User.
  final List<_BookRecord> _books = [
    const _BookRecord(
      id: 1,
      title: 'Laut Bercerita',
      author: 'Leila S. Chudori',
      category: 'Novel',
      stock: 12,
      condition: 'Baik',
      year: '',
      publisher: '',
      isbn: '',
      description: '',
      coverUrl: '',
    ),
    const _BookRecord(
      id: 2,
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      category: 'Sejarah',
      stock: 8,
      condition: 'Baik',
      year: '',
      publisher: '',
      isbn: '',
      description: '',
      coverUrl: '',
    ),
    const _BookRecord(
      id: 3,
      title: 'Filosofi Teras',
      author: 'Henry Manampiring',
      category: 'Pengembangan Diri',
      stock: 5,
      condition: 'Rusak Ringan',
      year: '',
      publisher: '',
      isbn: '',
      description: '',
      coverUrl: '',
    ),
    const _BookRecord(
      id: 4,
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Pengembangan Diri',
      stock: 9,
      condition: 'Baik',
      year: '',
      publisher: '',
      isbn: '',
      description: '',
      coverUrl: '',
    ),
    const _BookRecord(
      id: 5,
      title: 'Fisika Dasar',
      author: 'Halliday, Resnick, Walker',
      category: 'Pendidikan',
      stock: 0,
      condition: 'Perlu Perbaikan',
      year: '',
      publisher: '',
      isbn: '',
      description: '',
      coverUrl: '',
    ),
  ];

  String _selectedCategory = _categories.first;
  int _nextBookId = 6;

  List<_BookRecord> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();

    return _books.where((book) {
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == _categories.first ||
          book.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> _openBookForm({int? index}) async {
    final book = index == null ? null : _books[index];

    final result = await showDialog<_BookRecord>(
      context: context,
      builder: (context) => _BookFormDialog(
        book: book,
        newId: _nextBookId,
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        _books.insert(0, result);
        _nextBookId++;
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

    if (confirmed != true || !mounted) return;

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
                subtitle:
                'Kelola koleksi, ketersediaan, dan kondisi buku perpustakaan.',
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
        labelText: 'Cari buku, penulis, atau ISBN',
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
        child: Center(
          child: Text('Tidak ada buku yang sesuai dengan filter.'),
        ),
      );
    }

    return AdminDataTable(
      minWidth: 1100,
      rowHeight: 70,
      columnSpacing: 14,
      columns: const [
        DataColumn(label: AdminTableHeading('COVER & JUDUL', width: 190)),
        DataColumn(label: AdminTableHeading('PENULIS', width: 160)),
        DataColumn(label: AdminTableHeading('KATEGORI', width: 140)),
        DataColumn(label: AdminTableHeading('TAHUN', width: 70)),
        DataColumn(label: AdminTableHeading('PENERBIT', width: 130)),
        DataColumn(label: AdminTableHeading('STOK', width: 60)),
        DataColumn(label: AdminTableHeading('KONDISI', width: 140)),
        DataColumn(label: AdminTableHeading('AKSI', width: 100)),
      ],
      rows: _filteredBooks.map((book) {
        final index = _books.indexOf(book);

        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  _BookCoverThumbnail(
                    imageBytes: book.coverBytes,
                    imageUrl: book.coverUrl,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DataCell(Text(book.author)),
            DataCell(Text(book.category)),
            DataCell(Text(book.year.isEmpty ? '-' : book.year)),
            DataCell(Text(book.publisher.isEmpty ? '-' : book.publisher)),
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

class _BookCoverThumbnail extends StatelessWidget {
  const _BookCoverThumbnail({
    required this.imageBytes,
    required this.imageUrl,
  });

  final Uint8List? imageBytes;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageBytes != null) {
      image = Image.memory(
        imageBytes!,
        width: 42,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const _CoverPlaceholder(),
      );
    } else if (imageUrl.isNotEmpty) {
      image = Image.network(
        imageUrl,
        width: 42,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const _CoverPlaceholder(),
      );
    } else {
      image = const _CoverPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(width: 42, height: 56, child: image),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8E2D5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book_outlined,
        color: Color(0xFF71806A),
        size: 28,
      ),
    );
  }
}

class _BookRecord {
  const _BookRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.stock,
    required this.condition,
    required this.year,
    required this.publisher,
    required this.isbn,
    required this.description,
    required this.coverUrl,
    this.coverBytes,
  });

  final int id;
  final String title;
  final String author;
  final String category;
  final int stock;
  final String condition;
  final String year;
  final String publisher;
  final String isbn;
  final String description;
  final String coverUrl;

  // Data gambar sementara dalam memori aplikasi.
  final Uint8List? coverBytes;
}

class _BookFormDialog extends StatefulWidget {
  const _BookFormDialog({
    this.book,
    required this.newId,
  });

  final _BookRecord? book;
  final int newId;

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
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _stockController;
  late final TextEditingController _yearController;
  late final TextEditingController _publisherController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;

  late String _category;
  late String _condition;
  Uint8List? _coverBytes;
  bool _removeExistingUrlCover = false;

  @override
  void initState() {
    super.initState();

    final book = widget.book;

    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _stockController =
        TextEditingController(text: book == null ? '' : '${book.stock}');
    _yearController = TextEditingController(text: book?.year ?? '');
    _publisherController = TextEditingController(text: book?.publisher ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _descriptionController =
        TextEditingController(text: book?.description ?? '');

    _category = book?.category ?? _categories.first;
    _condition = book?.condition ?? _conditions.first;
    _coverBytes = book?.coverBytes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _stockController.dispose();
    _yearController.dispose();
    _publisherController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (selectedImage == null) return;

      final bytes = await selectedImage.readAsBytes();
      if (!mounted) return;

      setState(() {
        _coverBytes = bytes;
        _removeExistingUrlCover = true;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $error')),
      );
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverBytes = null;
      _removeExistingUrlCover = true;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final existingBook = widget.book;

    Navigator.pop(
      context,
      _BookRecord(
        id: existingBook?.id ?? widget.newId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _category,
        stock: int.parse(_stockController.text.trim()),
        condition: _condition,
        year: _yearController.text.trim(),
        publisher: _publisherController.text.trim(),
        isbn: _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        coverUrl: _removeExistingUrlCover
            ? ''
            : (existingBook?.coverUrl ?? ''),
        coverBytes: _coverBytes,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    return null;
  }

  String? _yearValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final year = int.tryParse(text);
    if (year == null || year < 0 || year > 9999) {
      return 'Masukkan tahun terbit yang valid.';
    }
    return null;
  }

  String? _stockValidator(String? value) {
    final stock = int.tryParse(value?.trim() ?? '');
    if (stock == null || stock < 0) {
      return 'Masukkan stok berupa angka nol atau lebih.';
    }
    return null;
  }

  Widget _buildCoverPicker() {
    final oldUrl = _removeExistingUrlCover ? '' : (widget.book?.coverUrl ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Foto Cover Buku',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F0E6),
            border: Border.all(color: const Color(0xFFD8D2C3)),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: _coverBytes != null
              ? Image.memory(
            _coverBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const _CoverPlaceholder(),
          )
              : oldUrl.isNotEmpty
              ? Image.network(
            oldUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const _CoverPlaceholder(),
          )
              : const _CoverPlaceholder(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickCoverImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _coverBytes == null ? 'Pilih dari Galeri' : 'Ganti Foto',
                ),
              ),
            ),
            if (_coverBytes != null || oldUrl.isNotEmpty) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Hapus foto cover',
                onPressed: _removeCoverImage,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFF9A4438),
              ),
            ],
          ],
        ),
        const Text(
          'Pilih gambar sampul dari galeri perangkat. Dalam versi demo ini, '
              'gambar disimpan sementara selama aplikasi berjalan.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width - 64;

    return AlertDialog(
      title: Text(widget.book == null ? 'Tambah Buku' : 'Edit Buku'),
      content: SizedBox(
        width: dialogWidth.clamp(0.0, 560.0),
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
                      DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
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
                    LabeledTextFormField(
                      label: 'Stok Buku',
                      controller: _stockController,
                      hintText: 'Jumlah stok',
                      keyboardType: TextInputType.number,
                      validator: _stockValidator,
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
                      label: 'Tahun Terbit',
                      controller: _yearController,
                      hintText: 'Contoh: 2020',
                      keyboardType: TextInputType.number,
                      validator: _yearValidator,
                    ),
                    const SizedBox(height: 16),
                    LabeledTextFormField(
                      label: 'Penerbit',
                      controller: _publisherController,
                      hintText: 'Masukkan nama penerbit',
                    ),
                    const SizedBox(height: 16),
                    LabeledTextFormField(
                      label: 'ISBN',
                      controller: _isbnController,
                      hintText: 'Masukkan nomor ISBN',
                    ),
                    const SizedBox(height: 16),
                    LabeledTextFormField(
                      label: 'Deskripsi',
                      controller: _descriptionController,
                      hintText: 'Masukkan deskripsi buku',
                    ),
                    const SizedBox(height: 16),
                    _buildCoverPicker(),
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
        FilledButton(
          onPressed: _save,
          child: const Text('Simpan Buku'),
        ),
      ],
    );
  }
}