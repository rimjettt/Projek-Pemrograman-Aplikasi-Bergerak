import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_frame.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_section_card.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/status_badge.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const List<String> _activities = [
    'Semua aktivitas',
    'Peminjaman Buku',
    'Pembatalan Peminjaman',
    'Pengajuan Pengembalian',
  ];
  static const List<String> _statuses = [
    'Semua status',
    'Disetujui',
    'Dibatalkan',
    'Dikembalikan',
    'Menunggu Verifikasi',
  ];

  final List<_HistoryEntry> _histories = const [
    _HistoryEntry(
      student: 'Alya Putri',
      book: 'Laut Bercerita',
      activity: 'Peminjaman Buku',
      status: 'Disetujui',
      date: '17 Nov 2026',
    ),
    _HistoryEntry(
      student: 'Bima Pratama',
      book: 'Bumi Manusia',
      activity: 'Pembatalan Peminjaman',
      status: 'Dibatalkan',
      date: '16 Nov 2026',
    ),
    _HistoryEntry(
      student: 'Citra Lestari',
      book: 'Filosofi Teras',
      activity: 'Pengajuan Pengembalian',
      status: 'Menunggu Verifikasi',
      date: '16 Nov 2026',
    ),
    _HistoryEntry(
      student: 'Danu Saputra',
      book: 'Atomic Habits',
      activity: 'Pengajuan Pengembalian',
      status: 'Dikembalikan',
      date: '15 Nov 2026',
    ),
    _HistoryEntry(
      student: 'Eka Wulandari',
      book: 'Laskar Pelangi',
      activity: 'Peminjaman Buku',
      status: 'Disetujui',
      date: '14 Nov 2026',
    ),
  ];

  String _selectedActivity = _activities.first;
  String _selectedStatus = _statuses.first;

  List<_HistoryEntry> get _filteredHistories {
    return _histories.where((history) {
      final matchesActivity =
          _selectedActivity == _activities.first ||
          history.activity == _selectedActivity;
      final matchesStatus =
          _selectedStatus == _statuses.first ||
          history.status == _selectedStatus;
      return matchesActivity && matchesStatus;
    }).toList();
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
                title: 'Riwayat Aktivitas',
                subtitle:
                    'Riwayat peminjaman, pengembalian, dan pembatalan buku.',
              ),
              const SizedBox(height: 16),
              _buildFilters(constraints.maxWidth),
              const SizedBox(height: 16),
              if (_filteredHistories.isEmpty)
                _buildEmptyState()
              else
                AdminSectionCard(
                  title: 'Daftar Riwayat',
                  subtitle: '${_filteredHistories.length} aktivitas',
                  child: _buildHistoryTable(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(double width) {
    final activityFilter = FilterDropdown(
      hint: 'Jenis aktivitas',
      value: _selectedActivity,
      options: _activities,
      prefixIcon: Icons.history,
      onChanged: (value) => setState(() => _selectedActivity = value),
    );
    final statusFilter = FilterDropdown(
      hint: 'Status',
      value: _selectedStatus,
      options: _statuses,
      prefixIcon: Icons.filter_alt_outlined,
      onChanged: (value) => setState(() => _selectedStatus = value),
    );

    if (width >= 620) {
      return Row(
        children: [
          Expanded(child: activityFilter),
          const SizedBox(width: 12),
          Expanded(child: statusFilter),
        ],
      );
    }

    return Column(
      children: [
        activityFilter,
        const SizedBox(height: 10),
        statusFilter,
      ],
    );
  }

  Widget _buildHistoryTable() {
    return AdminDataTable(
      minWidth: 1000,
      rowHeight: 60,
      columns: const [
        DataColumn(label: AdminTableHeading('NO.', width: 48)),
        DataColumn(
          label: AdminTableHeading('NAMA MAHASISWA', width: 150),
        ),
        DataColumn(label: AdminTableHeading('JUDUL BUKU', width: 150)),
        DataColumn(
          label: AdminTableHeading('JENIS AKTIVITAS', width: 160),
        ),
        DataColumn(label: AdminTableHeading('TANGGAL', width: 120)),
        DataColumn(label: AdminTableHeading('STATUS', width: 140)),
      ],
      rows: [
        for (var index = 0; index < _filteredHistories.length; index++)
          DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(
                Text(
                  _filteredHistories[index].student,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(Text(_filteredHistories[index].book)),
              DataCell(Text(_filteredHistories[index].activity)),
              DataCell(Text(_filteredHistories[index].date)),
              DataCell(StatusBadge(label: _filteredHistories[index].status)),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            Icon(Icons.history, color: AppColors.accent, size: 42),
            SizedBox(height: 8),
            Text(
              'Belum ada riwayat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Aktivitas admin akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.student,
    required this.book,
    required this.activity,
    required this.status,
    required this.date,
  });

  final String student;
  final String book;
  final String activity;
  final String status;
  final String date;
}
