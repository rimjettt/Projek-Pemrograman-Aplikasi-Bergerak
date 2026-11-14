import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/loan_history.dart';

class HistoryPage extends StatelessWidget {
  final List<LoanHistory> histories;

  const HistoryPage({
    super.key,
    required this.histories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Riwayat Aktivitas',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Riwayat peminjaman, pengembalian, dan pembatalan buku.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        if (histories.isEmpty)
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.history, color: accent, size: 42),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada riwayat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Aktivitas kamu akan muncul di halaman ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ...histories.map((history) {
          final IconData activityIcon;
          if (history.activity == 'Pengajuan Pengembalian') {
            activityIcon = Icons.assignment_return;
          } else if (history.activity == 'Pembatalan Peminjaman') {
            activityIcon = Icons.cancel_outlined;
          } else {
            activityIcon = Icons.menu_book;
          }

          return Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(activityIcon, color: accent, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        Text(
                          history.activity,
                          style: const TextStyle(
                            color: accent,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Status: ${history.status}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          history.date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
