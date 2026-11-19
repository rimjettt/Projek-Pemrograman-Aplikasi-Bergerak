import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/loan_history.dart';

/// Menu Riwayat tetap satu di bottom navigation.
/// Di dalamnya terdapat filter: Semua, Peminjaman, dan Pengembalian.
class HistoryPage extends StatelessWidget {
  final List<LoanHistory> histories;

  const HistoryPage({
    super.key,
    required this.histories,
  });

  bool _isReturnActivity(LoanHistory history) {
    return history.activity.toLowerCase().contains('pengembalian');
  }

  @override
  Widget build(BuildContext context) {
    // Data dari LibraryHome sudah diurutkan terbaru lebih dulu.
    final borrowing = histories
        .where((history) => !_isReturnActivity(history))
        .toList();
    final returning = histories
        .where(_isReturnActivity)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Riwayat',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: pale,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                isScrollable: false,
                labelColor: navy,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Peminjaman'),
                  Tab(text: 'Pengembalian'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                _HistoryList(
                  histories: histories,
                  emptyMessage: 'Belum ada riwayat aktivitas.',
                ),
                _HistoryList(
                  histories: borrowing,
                  emptyMessage: 'Belum ada riwayat peminjaman.',
                ),
                _HistoryList(
                  histories: returning,
                  emptyMessage: 'Belum ada riwayat pengembalian.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<LoanHistory> histories;
  final String emptyMessage;

  const _HistoryList({
    required this.histories,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.history, color: accent, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: histories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final history = histories[index];
        final isReturn =
        history.activity.toLowerCase().contains('pengembalian');
        final isCanceled =
        history.activity.toLowerCase().contains('pembatalan');
        final icon = isReturn
            ? Icons.assignment_return_outlined
            : isCanceled
            ? Icons.cancel_outlined
            : Icons.menu_book_outlined;

        final status = history.status.toLowerCase();
        final Color statusColor;
        if (status.contains('ditolak') || status.contains('dibatalkan')) {
          statusColor = Colors.red.shade700;
        } else if (status.contains('selesai') ||
            status.contains('disetujui') ||
            status.contains('dikembalikan')) {
          statusColor = navy;
        } else {
          statusColor = accent;
        }

        return Card(
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: pale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: navy, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.book.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        history.activity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Status: ${history.status}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        history.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
