import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_frame.dart';
import '../widgets/admin_section_card.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final List<_LoanRequest> _loanRequests = [
    _LoanRequest(
      student: 'Alya Putri',
      book: 'Laut Bercerita',
      requestDate: '17 Nov 2026',
      dueDate: '24 Nov 2026',
    ),
    _LoanRequest(
      student: 'Bima Pratama',
      book: 'Bumi Manusia',
      requestDate: '17 Nov 2026',
      dueDate: '24 Nov 2026',
    ),
    _LoanRequest(
      student: 'Citra Lestari',
      book: 'Filosofi Teras',
      requestDate: '16 Nov 2026',
      dueDate: '23 Nov 2026',
    ),
    _LoanRequest(
      student: 'Danu Saputra',
      book: 'Atomic Habits',
      requestDate: '16 Nov 2026',
      dueDate: '23 Nov 2026',
      status: _RequestStatus.rejected,
    ),
  ];

  final List<_ReturnRequest> _returnRequests = [
    _ReturnRequest(
      student: 'Eka Wulandari',
      book: 'Laskar Pelangi',
      requestDate: '17 Nov 2026',
      condition: 'Baik',
    ),
    _ReturnRequest(
      student: 'Fajar Ramadhan',
      book: 'Negeri 5 Menara',
      requestDate: '16 Nov 2026',
      condition: 'Sampul sedikit rusak',
    ),
    _ReturnRequest(
      student: 'Gita Ananda',
      book: 'Perahu Kertas',
      requestDate: '15 Nov 2026',
      condition: 'Baik',
    ),
  ];

  void _updateLoan(int index, _RequestStatus status) {
    setState(() {
      _loanRequests[index] = _loanRequests[index].copyWith(status: status);
    });
    _showMessage(
      status == _RequestStatus.approved
          ? 'Pengajuan peminjaman disetujui.'
          : 'Pengajuan peminjaman ditolak.',
    );
  }

  void _verifyReturn(int index) {
    setState(() {
      _returnRequests[index] = _returnRequests[index].copyWith(
        status: _RequestStatus.verified,
      );
    });
    _showMessage('Pengembalian buku berhasil diverifikasi.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageFrame(
            verticalPadding: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Peminjaman',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola pengajuan peminjaman dan pengembalian buku.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.navy,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    indicatorColor: AppColors.accent,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Peminjaman Buku'),
                      Tab(text: 'Pengembalian Buku'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AdminPageFrame(
              verticalPadding: 0,
              child: TabBarView(
                children: [
                  _RequestList(
                    title: 'Pengajuan Peminjaman',
                    description:
                        'Tinjau dan proses permintaan peminjaman buku mahasiswa.',
                    minWidth: 1200,
                    columnSpacing: 12,
                    columns: const [
                      DataColumn(
                        label: AdminTableHeading(
                          'NAMA MAHASISWA',
                          width: 150,
                        ),
                      ),
                      DataColumn(
                        label: AdminTableHeading('JUDUL BUKU', width: 140),
                      ),
                      DataColumn(
                        label: AdminTableHeading(
                          'TANGGAL PENGAJUAN',
                          width: 160,
                        ),
                      ),
                      DataColumn(
                        label: AdminTableHeading(
                          'TANGGAL JATUH TEMPO',
                          width: 160,
                        ),
                      ),
                      DataColumn(label: AdminTableHeading('STATUS', width: 120)),
                      DataColumn(label: AdminTableHeading('AKSI', width: 150)),
                    ],
                    rows: [
                      for (var index = 0;
                          index < _loanRequests.length;
                          index++)
                        _RequestRow(
                          cells: [
                            _loanRequests[index].student,
                            _loanRequests[index].book,
                            _loanRequests[index].requestDate,
                            _loanRequests[index].dueDate,
                          ],
                          status: _loanRequests[index].status,
                          actions: _loanRequests[index].status ==
                                  _RequestStatus.pending
                              ? Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: [
                                    _ActionButton(
                                      label: 'Setujui',
                                      icon: Icons.check_rounded,
                                      isPrimary: true,
                                      onPressed: () => _updateLoan(
                                        index,
                                        _RequestStatus.approved,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _ActionButton(
                                      label: 'Tolak',
                                      icon: Icons.close_rounded,
                                      isPrimary: false,
                                      onPressed: () => _updateLoan(
                                        index,
                                        _RequestStatus.rejected,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                    ],
                  ),
                  _RequestList(
                    title: 'Pengajuan Pengembalian',
                    description:
                        'Periksa kondisi buku dan verifikasi pengajuan pengembalian.',
                    minWidth: 1240,
                    columnSpacing: 12,
                    columns: const [
                      DataColumn(
                        label: AdminTableHeading(
                          'NAMA MAHASISWA',
                          width: 150,
                        ),
                      ),
                      DataColumn(
                        label: AdminTableHeading('JUDUL BUKU', width: 140),
                      ),
                      DataColumn(
                        label: AdminTableHeading(
                          'TANGGAL PENGAJUAN',
                          width: 160,
                        ),
                      ),
                      DataColumn(
                        label: AdminTableHeading('KONDISI BUKU', width: 150),
                      ),
                      DataColumn(label: AdminTableHeading('STATUS', width: 120)),
                      DataColumn(label: AdminTableHeading('AKSI', width: 180)),
                    ],
                    rows: [
                      for (var index = 0;
                          index < _returnRequests.length;
                          index++)
                        _RequestRow(
                          cells: [
                            _returnRequests[index].student,
                            _returnRequests[index].book,
                            _returnRequests[index].requestDate,
                            _returnRequests[index].condition,
                          ],
                          status: _returnRequests[index].status,
                          actions: _returnRequests[index].status ==
                                  _RequestStatus.awaitingVerification
                              ? _ActionButton(
                                  label: 'Verifikasi Pengembalian',
                                  icon: Icons.verified_outlined,
                                  isPrimary: true,
                                  onPressed: () => _verifyReturn(index),
                                )
                              : null,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.title,
    required this.description,
    required this.minWidth,
    required this.columnSpacing,
    required this.columns,
    required this.rows,
  });

  final String title;
  final String description;
  final double minWidth;
  final double columnSpacing;
  final List<DataColumn> columns;
  final List<_RequestRow> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminSectionCard(
        title: title,
        subtitle: description,
        child: AdminDataTable(
          minWidth: minWidth,
          rowHeight: 76,
          columnSpacing: columnSpacing,
          columns: columns,
          rows: [
            for (final row in rows)
              DataRow(
                cells: [
                  for (final cell in row.cells)
                    DataCell(
                      Text(
                        cell,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  DataCell(_StatusBadge(status: row.status)),
                  DataCell(
                    row.actions ??
                        const Text(
                          '—',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pale,
          foregroundColor: AppColors.navy,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9A4438),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      _RequestStatus.pending => (
          'Menunggu Persetujuan',
          AppColors.pale,
          const Color(0xFF8A642D),
        ),
      _RequestStatus.approved => (
          'Disetujui',
          const Color(0xFFE7F1E9),
          AppColors.navy,
        ),
      _RequestStatus.rejected => (
          'Ditolak',
          const Color(0xFFF8E7E4),
          const Color(0xFF9A4438),
        ),
      _RequestStatus.awaitingVerification => (
          'Menunggu Verifikasi',
          AppColors.pale,
          const Color(0xFF8A642D),
        ),
      _RequestStatus.verified => (
          'Terverifikasi',
          const Color(0xFFE7F1E9),
          AppColors.navy,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _RequestRow {
  const _RequestRow({
    required this.cells,
    required this.status,
    this.actions,
  });

  final List<String> cells;
  final _RequestStatus status;
  final Widget? actions;
}

enum _RequestStatus {
  pending,
  approved,
  rejected,
  awaitingVerification,
  verified,
}

class _LoanRequest {
  const _LoanRequest({
    required this.student,
    required this.book,
    required this.requestDate,
    required this.dueDate,
    this.status = _RequestStatus.pending,
  });

  final String student;
  final String book;
  final String requestDate;
  final String dueDate;
  final _RequestStatus status;

  _LoanRequest copyWith({_RequestStatus? status}) {
    return _LoanRequest(
      student: student,
      book: book,
      requestDate: requestDate,
      dueDate: dueDate,
      status: status ?? this.status,
    );
  }
}

class _ReturnRequest {
  const _ReturnRequest({
    required this.student,
    required this.book,
    required this.requestDate,
    required this.condition,
    this.status = _RequestStatus.awaitingVerification,
  });

  final String student;
  final String book;
  final String requestDate;
  final String condition;
  final _RequestStatus status;

  _ReturnRequest copyWith({_RequestStatus? status}) {
    return _ReturnRequest(
      student: student,
      book: book,
      requestDate: requestDate,
      condition: condition,
      status: status ?? this.status,
    );
  }
}
