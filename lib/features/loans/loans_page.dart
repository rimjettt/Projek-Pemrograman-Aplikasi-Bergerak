import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/loan.dart';

class LoansPage extends StatelessWidget {
  final List<Loan> loans;
  final ValueChanged<Loan> onCancelLoan;
  final ValueChanged<Loan> onReturnRequest;

  const LoansPage({
    super.key,
    required this.loans,
    required this.onCancelLoan,
    required this.onReturnRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Peminjaman Saya',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 12),
        if (loans.isEmpty)
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.bookmark_border, color: accent, size: 42),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada peminjaman',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Pengajuan buku yang aktif akan ditampilkan di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ...loans.map(
          (loan) => Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status peminjaman: ${loan.status}',
                    style: const TextStyle(
                      color: accent,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Jatuh tempo: ${loan.dueDate}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (loan.returnStatus == null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => onCancelLoan(loan),
                          child: const Text('Batalkan'),
                        ),
                        FilledButton.icon(
                          onPressed: () => onReturnRequest(loan),
                          icon: const Icon(Icons.assignment_return),
                          label: const Text('Ajukan Pengembalian'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Status pengembalian: ${loan.returnStatus}',
                      style: const TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pengembalian menunggu pemeriksaan petugas perpustakaan.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
