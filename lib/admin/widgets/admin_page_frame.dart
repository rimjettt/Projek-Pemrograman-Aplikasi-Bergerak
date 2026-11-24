import 'package:flutter/material.dart';

class AdminPageFrame extends StatelessWidget {
  const AdminPageFrame({
    required this.child,
    this.maxWidth = 1440,
    this.verticalPadding = 24,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 600
            ? 16.0
            : width < 1024
            ? 24.0
            : 32.0;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
