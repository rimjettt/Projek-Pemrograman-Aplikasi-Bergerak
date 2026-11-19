import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_frame.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_section_card.dart';
import '../widgets/status_badge.dart';

class ViolationsPage extends StatefulWidget {
  const ViolationsPage({super.key});

  @override
  State<ViolationsPage> createState() => _ViolationsPageState();
}

class _ViolationsPageState extends State<ViolationsPage> {
  final List<_ViolationRecord> _violations = [
    _ViolationRecord(
      student: 'Danu Saputra',
      book: 'Atomic Habits',
      type: 'Terlambat mengembalikan',
      date: '17 Nov 2026',
      verified: false,
      suspended: false,
    ),
    _ViolationRecord(
      student: 'Gita Ananda',
      book: 'Perahu Kertas',
      type: 'Kerusakan ringan',
      date: '15 Nov 2026',
      verified: true,
      suspended: true,
    ),
    _ViolationRecord(
      student: 'Hana Maharani',
      book: 'Laskar Pelangi',
      type: 'Buku belum dikembalikan',
      date: '14 Nov 2026',
      verified: false,
      suspended: false,
    ),
  ];

  void _verify(int index) {
    setState(() {
      _violations[index] = _violations[index].copyWith(verified: true);
    });
    _showMessage('Pelanggaran berhasil diverifikasi.');
  }

  void _toggleSuspend(int index) {
    final suspended = !_violations[index].suspended;
    setState(() {
      _violations[index] = _violations[index].copyWith(
        suspended: suspended,
      );
    });
    _showMessage(
      suspended
          ? 'Akun mahasiswa telah disuspend.'
          : 'Suspend akun mahasiswa telah dicabut.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminPageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminPageHeader(
              title: 'Pelanggaran',
              subtitle:
                  'Tinjau pelanggaran perpustakaan dan kelola status suspend mahasiswa.',
            ),
            const SizedBox(height: 20),
            AdminSectionCard(
              title: 'Daftar Pelanggaran',
              subtitle: '${_violations.length} catatan pelanggaran',
              child: _buildViolationTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationTable() {
    return AdminDataTable(
      minWidth: 1280,
      rowHeight: 84,
      columnSpacing: 12,
      columns: const [
        DataColumn(
          label: AdminTableHeading('NAMA MAHASISWA', width: 155),
        ),
        DataColumn(label: AdminTableHeading('BUKU', width: 120)),
        DataColumn(
          label: AdminTableHeading('JENIS PELANGGARAN', width: 165),
        ),
        DataColumn(label: AdminTableHeading('TANGGAL', width: 110)),
        DataColumn(
          label: AdminTableHeading('STATUS SUSPEND', width: 150),
        ),
        DataColumn(label: AdminTableHeading('AKSI', width: 190)),
      ],
      rows: [
        for (var index = 0; index < _violations.length; index++)
          DataRow(
            cells: [
              DataCell(
                Text(
                  _violations[index].student,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(Text(_violations[index].book)),
              DataCell(Text(_violations[index].type)),
              DataCell(Text(_violations[index].date)),
              DataCell(
                StatusBadge(
                  label: _violations[index].suspended
                      ? 'Ditangguhkan'
                      : 'Aktif',
                ),
              ),
              DataCell(
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    if (_violations[index].verified)
                      const Tooltip(
                        message: 'Terverifikasi',
                        child: Icon(
                          Icons.verified,
                          color: AppColors.navy,
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: () => _verify(index),
                        icon: const Icon(Icons.verified_outlined, size: 18),
                        label: const Text('Verifikasi'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      ),
                    OutlinedButton(
                      onPressed: () => _toggleSuspend(index),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _violations[index].suspended
                            ? AppColors.navy
                            : const Color(0xFF9A4438),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        _violations[index].suspended
                            ? 'Cabut Suspend'
                            : 'Suspend',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ViolationRecord {
  const _ViolationRecord({
    required this.student,
    required this.book,
    required this.type,
    required this.date,
    required this.verified,
    required this.suspended,
  });

  final String student;
  final String book;
  final String type;
  final String date;
  final bool verified;
  final bool suspended;

  _ViolationRecord copyWith({bool? verified, bool? suspended}) {
    return _ViolationRecord(
      student: student,
      book: book,
      type: type,
      date: date,
      verified: verified ?? this.verified,
      suspended: suspended ?? this.suspended,
    );
  }
}
