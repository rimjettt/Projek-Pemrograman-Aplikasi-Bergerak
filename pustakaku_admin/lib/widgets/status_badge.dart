import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (label) {
      'Baik' ||
      'Tersedia' ||
      'Terverifikasi' ||
      'Disetujui' ||
      'Dikembalikan' ||
      'Aktif' => (const Color(0xFFE7F1E9), AppColors.navy),
      'Rusak Ringan' || 'Menunggu Verifikasi' || 'Menunggu Persetujuan' => (
          AppColors.pale,
          const Color(0xFF8A642D),
        ),
      'Perlu Perbaikan' ||
      'Ditolak' ||
      'Dibatalkan' ||
      'Ditangguhkan' ||
      'Suspend' => (
          const Color(0xFFF8E7E4),
          const Color(0xFF9A4438),
        ),
      _ => (AppColors.pale, AppColors.textPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
