import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../core/date_formatter.dart';
import '../../data/book_data.dart';
import '../../models/book.dart';
import '../../models/loan.dart';
import '../../models/loan_history.dart';
import '../../models/student_profile.dart';
import '../catalog/book_detail_page.dart';
import '../catalog/catalog_page.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import '../loans/loans_page.dart';
import '../profile/profile_page.dart';

class LibraryHome extends StatefulWidget {
  final StudentProfile profile;
  final ValueChanged<StudentProfile> onSaveProfile;
  final VoidCallback onLogout;

  const LibraryHome({
    super.key,
    required this.profile,
    required this.onSaveProfile,
    required this.onLogout,
  });

  @override
  State<LibraryHome> createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  int selectedTab = 0;
  String catalogQuery = '';
  String homeQuery = '';
  late List<Book> books;
  final List<Loan> loans = [];
  final List<LoanHistory> histories = [];
  Book? selectedBook;

  late final TextEditingController homeSearchController;
  late final TextEditingController catalogSearchController;

  @override
  void initState() {
    super.initState();
    homeSearchController = TextEditingController();
    catalogSearchController = TextEditingController();

    // Salin data awal supaya perubahan stok tidak mengubah data sumber.
    books = initialBooks
        .map(
          (book) => Book(
        id: book.id,
        title: book.title,
        author: book.author,
        category: book.category,
        stock: book.stock,
        coverUrl: book.coverUrl,
        isbn: book.isbn,
        year: book.year,
        publisher: book.publisher,
        description: book.description,
      ),
    )
        .toList();
  }

  @override
  void dispose() {
    homeSearchController.dispose();
    catalogSearchController.dispose();
    super.dispose();
  }

  List<Book> _filterBooks(String query) {
    final keyword = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(keyword) ||
          book.author.toLowerCase().contains(keyword) ||
          book.category.toLowerCase().contains(keyword);
    }).toList();
  }

  void _showNotice(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('PustakaKu'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    return DateTime(int.tryParse(parts[2]) ?? 0, int.tryParse(parts[1]) ?? 0, int.tryParse(parts[0]) ?? 0);
  }

  void _submitBorrow(Book book, DateTime borrowDate) {
    final alreadyApplied = loans.any((loan) => loan.book.id == book.id);

    if (alreadyApplied) {
      _showNotice('Buku ini sudah diajukan.');
      return;
    }

    if (book.stock < 1) {
      _showNotice('Stok buku sedang habis.');
      return;
    }

    setState(() {
      loans.add(Loan(book, borrowerName: widget.profile.name, initialCondition: 'Baik', borrowDate: _dateLabel(borrowDate), dueDate: _dateLabel(borrowDate.add(const Duration(days: 7)))));
      book.stock--;
      histories.insert(
        0,
        LoanHistory(
          book: book,
          activity: 'Peminjaman Buku',
          status: 'Menunggu persetujuan',
          date: formatCurrentDate(),
        ),
      );
      selectedBook = null;
      selectedTab = 2;
    });
    _showNotice(
      'Pengajuan peminjaman disimpan. Menunggu persetujuan petugas.',
    );
  }

  void _cancelLoan(Loan loan) {
    setState(() {
      loans.removeWhere((item) => item.book.id == loan.book.id);
      loan.book.stock++;
      histories.insert(
        0,
        LoanHistory(
          book: loan.book,
          activity: 'Pembatalan Peminjaman',
          status: 'Dibatalkan',
          date: formatCurrentDate(),
        ),
      );
    });
    _showNotice('Pengajuan peminjaman dibatalkan.');
  }

  Future<void> _requestReturn(Loan loan) async {
    if (loan.returnStatus != null) return;

    final notesController = TextEditingController();
    String? condition;
    bool returnFormVisible = false;
    String photoPath = '';
    final picker = ImagePicker();
    final submission = await showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Form Pengajuan Peminjaman & Pengembalian', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formReadOnly('Nama peminjam', loan.borrowerName.isEmpty ? widget.profile.name : loan.borrowerName),
                  _formReadOnly('Nama buku', loan.book.title),
                  _formReadOnly('Tanggal peminjaman', '${loan.borrowDate} - ${loan.dueDate}'),
                  _formReadOnly('Kondisi buku saat dipinjam', loan.initialCondition),
                  const Text('Foto kondisi awal buku', style: TextStyle(fontWeight: FontWeight.w600)),
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 14),
                    padding: const EdgeInsets.all(14),
                    width: double.infinity,
                    decoration: BoxDecoration(color: pale, borderRadius: BorderRadius.circular(12)),
                    child: const Column(children: [Icon(Icons.image_outlined, color: navy, size: 30),
                      SizedBox(height: 5), Text('Foto kondisi awal disediakan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))]),
                  ),
                  Row(
                    children: [
                      const Text('Form pengembalian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        iconSize: 30,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        tooltip: returnFormVisible ? 'Sembunyikan form pengembalian' : 'Tampilkan form pengembalian',
                        onPressed: () {
                          setDialogState(() {
                            returnFormVisible = !returnFormVisible;
                          });
                        },
                        icon: Icon(returnFormVisible ? Icons.remove_circle : Icons.add_circle, color: navy, size: 30),
                      ),
                    ],
                  ),
                  if (returnFormVisible) ...[
                    const SizedBox(height: 4),
                    const Text('Kondisi buku saat dikembalikan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...['Baik', 'Rusak ringan', 'Rusak berat', 'Hilang'].map((item) => RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(item),
                      value: item,
                      groupValue: condition,
                      onChanged: (value) => setDialogState(() => condition = value),
                    )),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Keterangan tambahan', hintText: 'Jelaskan kondisi buku atau hal yang ingin disampaikan...'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Upload foto buku (kondisi saat akan dikembalikan)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) setDialogState(() => photoPath = image.path);
                      },
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(photoPath.isEmpty ? 'Tambah Foto' : 'Ganti Foto'),
                    ),
                    if (photoPath.isNotEmpty) Text('Foto dipilih: ${photoPath.split('/').last}', style: const TextStyle(fontSize: 12)),
                  ] else
                    const Text('Tekan tanda + untuk membuka form pengembalian.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            if (returnFormVisible)
              FilledButton(
                onPressed: condition != null && photoPath.isNotEmpty
                    ? () => Navigator.pop(dialogContext, {'condition': condition!, 'notes': notesController.text.trim(), 'photo': photoPath})
                    : null,
                child: const Text('Kirim Pengajuan Pengembalian'),
              ),
          ],
        ),
      ),
    );
    notesController.dispose();
    if (submission == null) return;

    final loanIndex = loans.indexWhere((item) => item.book.id == loan.book.id);
    if (loanIndex == -1) return;
    final updatedLoan = loan.copyWith(
      returnStatus: 'Menunggu persetujuan admin',
      returnCondition: submission['condition'],
      returnNotes: submission['notes'] ?? '',
      returnPhotoPath: submission['photo'] ?? '',
    );
    setState(() {
      loans[loanIndex] = updatedLoan;
      histories.insert(0, LoanHistory(
        book: loan.book,
        activity: 'Pengajuan Pengembalian',
        status: 'Menunggu persetujuan admin',
        date: formatCurrentDate(),
        condition: submission['condition'],
        notes: submission['notes'],
        photoPath: submission['photo'],
      ));
    });
    _showNotice('Pengajuan pengembalian berhasil dikirim dan menunggu konfirmasi admin.');
  }


  void _showReminders() {
    final today = DateTime.now();
    final reminders = <String>[];
    for (final loan in loans) {
      final due = _parseDate(loan.dueDate);
      if (due == null) continue;
      final dueDay = DateTime(due.year, due.month, due.day);
      final todayDay = DateTime(today.year, today.month, today.day);
      final days = dueDay.difference(todayDay).inDays;
      final title = loan.book.title;
      if (days == 2) reminders.add('H-2: $title harus dikembalikan pada ${loan.dueDate}.');
      if (days == 1) reminders.add('H-1: Besok batas pengembalian $title (${loan.dueDate}).');
      if (days == 0) reminders.add('Hari ini jatuh tempo pengembalian $title.');
    }
    _showNotice(reminders.isEmpty ? 'Belum ada pengingat pengembalian.' : reminders.join('\\n\\n'));
  }

  Widget _formReadOnly(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w800)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
  );

  void _selectBook(Book book) {
    setState(() => selectedBook = book);
  }

  void _changeTab(int index) {
    setState(() {
      selectedTab = index;
      selectedBook = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        profile: widget.profile,
        books: books,
        loanCount: loans.length,
        searchQuery: homeQuery,
        searchController: homeSearchController,
        onSearchChanged: (value) => setState(() => homeQuery = value),
        onOpenCatalog: () => _changeTab(1),
        onSelectBook: _selectBook,
      ),
      CatalogPage(
        books: books,
        query: catalogQuery,
        searchController: catalogSearchController,
        onSearchChanged: (value) => setState(() => catalogQuery = value),
        onSelectBook: _selectBook,
      ),
      LoansPage(
        loans: loans,
        onCancelLoan: _cancelLoan,
        onReturnRequest: _requestReturn,
      ),
      HistoryPage(histories: histories),
      ProfilePage(
        profile: widget.profile,
        onSave: (profile) {
          widget.onSaveProfile(profile);
          _showNotice('Profil berhasil diperbarui.');
        },
        onLogout: widget.onLogout,
      ),
    ];

    final detailBook = selectedBook;
    final body = detailBook == null
        ? pages[selectedTab]
        : BookDetailPage(
      book: detailBook,
      profile: widget.profile,
      alreadyApplied: loans.any(
            (loan) => loan.book.id == detailBook.id,
      ),
      onBack: () => setState(() => selectedBook = null),
      onBorrow: (date) => _submitBorrow(detailBook, date),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_pustakaku.png',
              width: 65,
              height: 42,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PustakaKu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navy,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Perpustakaan Digital',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showReminders,
            icon: const Icon(
              Icons.notifications_none,
              color: navy,
            ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark_added),
            label: 'Pinjaman',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
