import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AdminTableHeading extends StatelessWidget {
  const AdminTableHeading(this.label, {this.width = 132, super.key});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class AdminDataTable extends StatefulWidget {
  const AdminDataTable({
    required this.columns,
    required this.rows,
    required this.minWidth,
    this.rowHeight = 64,
    this.columnSpacing = 18,
    super.key,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double minWidth;
  final double rowHeight;
  final double columnSpacing;

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.minWidth;
        final needsHorizontalScroll = viewportWidth < widget.minWidth;
        final tableWidth = needsHorizontalScroll
            ? widget.minWidth
            : viewportWidth;
        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: needsHorizontalScroll,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: DataTable(
                headingRowHeight: 56,
                dataRowMinHeight: widget.rowHeight,
                dataRowMaxHeight: widget.rowHeight,
                horizontalMargin: 12,
                columnSpacing: widget.columnSpacing,
                headingTextStyle: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                dataTextStyle: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textPrimary),
                columns: widget.columns,
                rows: widget.rows,
              ),
            ),
          ),
        );
      },
    );
  }
}
