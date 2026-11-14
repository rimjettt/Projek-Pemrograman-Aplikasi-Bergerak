import 'package:flutter/material.dart';

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

  void _submitBorrow(Book book) {
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
      loans.add(Loan(book));
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

  void _requestReturn(Loan loan) {
    if (loan.returnStatus != null) return;

    final loanIndex = loans.indexWhere(
      (item) => item.book.id == loan.book.id,
    );
    if (loanIndex == -1) return;

    setState(() {
      loans[loanIndex] = loan.copyWith(returnStatus: 'Sedang Diproses');
      histories.insert(
        0,
        LoanHistory(
          book: loan.book,
          activity: 'Pengajuan Pengembalian',
          status: 'Sedang Diproses',
          date: formatCurrentDate(),
        ),
      );
    });
    _showNotice(
      'Pengajuan pengembalian berhasil dikirim dan sedang diproses.',
    );
  }

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
            onBorrow: () => _submitBorrow(detailBook),
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
            onPressed: () => _showNotice('Belum ada notifikasi baru.'),
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
