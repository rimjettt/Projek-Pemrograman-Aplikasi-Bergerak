import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_frame.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminPageFrame(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcome(context),
              const SizedBox(height: 24),
              _buildStatistics(constraints.maxWidth),
              const SizedBox(height: 24),
              const _FineActivityChartCard(),
              const SizedBox(height: 24),
              const _ActivityChartCard(),
              const SizedBox(height: 24),
              const _RecentLoansCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang, Admin',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Berikut ringkasan aktivitas perpustakaan PustakaKu.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatistics(double width) {
    final columns = width >= 1050
        ? 4
        : width >= 600
        ? 2
        : 1;
    final cardWidth = (width - 16 * (columns - 1)) / columns;
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: cardWidth / 172,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        StatCard(
          title: 'Total Buku',
          value: '2.480',
          icon: Icons.menu_book_outlined,
          iconColor: AppColors.navy,
        ),
        StatCard(
          title: 'Total Mahasiswa',
          value: '1.254',
          icon: Icons.groups_outlined,
          iconColor: AppColors.accent,
        ),
        StatCard(
          title: 'Peminjaman Aktif',
          value: '186',
          icon: Icons.bookmark_added_outlined,
          iconColor: Color(0xFF568C6B),
        ),
        StatCard(
          title: 'Menunggu Persetujuan',
          value: '24',
          icon: Icons.pending_actions_outlined,
          iconColor: Color(0xFFB77C32),
        ),
      ],
    );
  }
}


class _FineActivityChartCard extends StatelessWidget {
  const _FineActivityChartCard();

  // DATA DEMO: total nominal denda setiap bulan.
  static const List<double> _fineValues = [
    150000,
    250000,
    100000,
    350000,
    200000,
    450000,
    300000,
    500000,
    175000,
    400000,
    600000,
    275000,
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'Mei', 'Jun', 'Jul', 'Agu',
    'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _rupiah(double value) {
    return 'Rp${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final total = _fineValues.reduce((a, b) => a + b);
    final maxValue = _fineValues.reduce((a, b) => a > b ? a : b);
    final maxIndex = _fineValues.indexOf(maxValue);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitas Denda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total nominal denda berdasarkan bulan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.pale.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    color: AppColors.navy,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Denda (Data Demo)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _rupiah(total),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tertinggi: ${_months[maxIndex]} • ${_rupiah(maxValue)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(
                painter: _FineChartPainter(_fineValues, _months),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> months;

  const _FineChartPainter(this.values, this.months);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 12.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 28.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final barWidth = chartWidth / values.length * 0.52;
    final slotWidth = chartWidth / values.length;

    final gridPaint = Paint()
      ..color = AppColors.pale
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = top + chartHeight * i / 4;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    for (var i = 0; i < values.length; i++) {
      final barHeight = chartHeight * values[i] / maxValue;
      final x = left + slotWidth * i + (slotWidth - barWidth) / 2;
      final y = top + chartHeight - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(5),
      );

      canvas.drawRRect(
        rect,
        Paint()..color = AppColors.navy,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: months[i],
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          size.height - 18,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.months != months;
  }
}

class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aktivitas Peminjaman',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jumlah peminjaman buku selama enam bulan terakhir',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 230,
              width: double.infinity,
              child: CustomPaint(painter: _ActivityChartPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityChartPainter extends CustomPainter {
  const _ActivityChartPainter();

  static const List<double> _values = [34, 48, 41, 66, 58, 83];
  static const List<String> _months = [
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 12.0;
    const top = 10.0;
    const bottom = 28.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final gridPaint = Paint()
      ..color = AppColors.pale
      ..strokeWidth = 1;
    final labelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontFamily: ThemeData().textTheme.bodySmall?.fontFamily,
    );

    for (var index = 0; index <= 4; index++) {
      final y = top + chartHeight * index / 4;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
      _drawLabel(
        canvas,
        '${100 - index * 25}',
        Offset(0, y - 7),
        labelStyle,
        width: left - 8,
        align: TextAlign.right,
      );
    }

    final points = List<Offset>.generate(_values.length, (index) {
      final x = left + chartWidth * index / (_values.length - 1);
      final y = top + chartHeight * (1 - _values[index] / 100);
      return Offset(x, y);
    });

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, top + chartHeight)
      ..lineTo(points.first.dx, top + chartHeight)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = AppColors.navy.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.navy
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var index = 0; index < points.length; index++) {
      canvas.drawCircle(points[index], 4, Paint()..color = AppColors.white);
      canvas.drawCircle(
        points[index],
        4,
        Paint()
          ..color = AppColors.navy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawLabel(
        canvas,
        _months[index],
        Offset(points[index].dx - 20, size.height - 20),
        labelStyle,
        width: 40,
        align: TextAlign.center,
      );
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double width,
    required TextAlign align,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) => false;
}

class _RecentLoansCard extends StatelessWidget {
  const _RecentLoansCard();

  static const List<_Loan> _loans = [
    _Loan(
      'Alya Putri',
      'Laut Bercerita',
      '17 Nov 2026',
      '24 Nov 2026',
      'Aktif',
    ),
    _Loan(
      'Bima Pratama',
      'Bumi Manusia',
      '17 Nov 2026',
      '24 Nov 2026',
      'Menunggu',
    ),
    _Loan(
      'Citra Lestari',
      'Filosofi Teras',
      '16 Nov 2026',
      '23 Nov 2026',
      'Aktif',
    ),
    _Loan(
      'Danu Saputra',
      'Atomic Habits',
      '16 Nov 2026',
      '23 Nov 2026',
      'Terlambat',
    ),
    _Loan(
      'Eka Wulandari',
      'Laskar Pelangi',
      '15 Nov 2026',
      '22 Nov 2026',
      'Aktif',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Peminjaman Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Daftar transaksi peminjaman buku terbaru',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            AdminDataTable(
              minWidth: 980,
              rowHeight: 58,
              columnSpacing: 18,
              columns: const [
                DataColumn(
                  label: AdminTableHeading('MAHASISWA', width: 130),
                ),
                DataColumn(label: AdminTableHeading('JUDUL BUKU', width: 140)),
                DataColumn(
                  label: AdminTableHeading('TANGGAL PINJAM', width: 145),
                ),
                DataColumn(label: AdminTableHeading('JATUH TEMPO', width: 130)),
                DataColumn(label: AdminTableHeading('STATUS', width: 100)),
              ],
              rows: _loans.map((loan) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        loan.student,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(Text(loan.book)),
                    DataCell(Text(loan.borrowedAt)),
                    DataCell(Text(loan.dueAt)),
                    DataCell(_StatusBadge(status: loan.status)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (status) {
      'Aktif' => (const Color(0xFFE7F1E9), AppColors.navy),
      'Menunggu' => (const Color(0xFFF7EFD9), const Color(0xFF8A642D)),
      _ => (const Color(0xFFF8E7E4), const Color(0xFF9A4438)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foregroundColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Loan {
  const _Loan(
    this.student,
    this.book,
    this.borrowedAt,
    this.dueAt,
    this.status,
  );

  final String student;
  final String book;
  final String borrowedAt;
  final String dueAt;
  final String status;
}
