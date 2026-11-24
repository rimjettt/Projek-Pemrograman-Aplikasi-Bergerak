import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../pages/catalog_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/history_page.dart';
import '../pages/loans_page.dart';
import '../pages/profile_page.dart';
import '../pages/violations_page.dart';
import 'navbar.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  String _activePage = 'Dashboard';

  void _selectPage(String page) {
    setState(() {
      _activePage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: Column(
        children: [
          Navbar(activePage: _activePage, onPageSelected: _selectPage),
          Expanded(
            child: switch (_activePage) {
              'Dashboard' => const DashboardPage(),
              'Katalog Buku' => const CatalogPage(),
              'Peminjaman' => const LoansPage(),
              'Riwayat' => const HistoryPage(),
              'Pelanggaran' => const ViolationsPage(),
              'Profil' => const ProfilePage(),
              _ => const DashboardPage(),
            },
          ),
        ],
      ),
    );
  }
}
