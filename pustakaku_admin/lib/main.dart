import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'layouts/admin_layout.dart';

void main() {
  runApp(const PustakaKuAdminApp());
}

class PustakaKuAdminApp extends StatelessWidget {
  const PustakaKuAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PustakaKu Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AdminLayout(),
    );
  }
}
