import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pustakaku_admin/main.dart';

void main() {
  testWidgets('dashboard loads and navbar switches sections', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());
    expect(find.text('Selamat Datang, Admin'), findsOneWidget);

    await tester.tap(find.text('Katalog Buku').first);
    await tester.pumpAndSettle();
    expect(find.text('Daftar Buku'), findsOneWidget);

    await tester.tap(find.text('Dashboard').first);
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang, Admin'), findsOneWidget);
  });

  testWidgets('dashboard stat cards show no trend indicators', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());

    expect(find.text('Total Buku'), findsOneWidget);
    expect(find.text('2.480'), findsOneWidget);
    expect(find.text('Total Mahasiswa'), findsOneWidget);
    expect(find.text('1.254'), findsOneWidget);
    expect(find.text('Peminjaman Aktif'), findsOneWidget);
    expect(find.text('186'), findsOneWidget);
    expect(find.text('Menunggu Persetujuan'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up_rounded), findsNothing);
    expect(find.text('+8,2%'), findsNothing);
    expect(find.text('+5,4%'), findsNothing);
    expect(find.text('+12%'), findsNothing);
    expect(find.text('Perlu ditinjau'), findsNothing);
  });

  testWidgets('dashboard remains usable on a small screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());
    expect(find.text('Selamat Datang, Admin'), findsOneWidget);
    expect(tester.takeException(), isNull);

    const destinations = {
      'Katalog Buku': 'Daftar Buku',
      'Peminjaman': 'Peminjaman',
      'Riwayat': 'Riwayat Aktivitas',
      'Pelanggaran': 'Daftar Pelanggaran',
      'Profil': 'Profil Admin',
    };
    for (final destination in destinations.entries) {
      await tester.tap(find.byTooltip('Buka menu navigasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(destination.key).last);
      await tester.pumpAndSettle();
      expect(find.text(destination.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('loans page contains both request tabs and handles actions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());
    await tester.tap(find.text('Peminjaman').first);
    await tester.pumpAndSettle();

    expect(find.text('Peminjaman Buku'), findsOneWidget);
    expect(find.text('Pengembalian Buku'), findsOneWidget);
    expect(find.text('Menunggu Persetujuan'), findsNWidgets(3));

    await tester.tap(find.text('Setujui').first);
    await tester.pumpAndSettle();
    expect(find.text('Disetujui'), findsOneWidget);

    await tester.tap(find.text('Pengembalian Buku'));
    await tester.pumpAndSettle();
    expect(find.text('KONDISI BUKU'), findsOneWidget);
    await tester.tap(find.text('Verifikasi Pengembalian').first);
    await tester.pumpAndSettle();
    expect(find.text('Terverifikasi'), findsOneWidget);
  });

  testWidgets('catalog supports adding, editing, searching, and deleting', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());
    await tester.tap(find.text('Katalog Buku').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah Buku'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Buku Tes');
    await tester.enterText(find.byType(TextFormField).at(1), 'Penulis Tes');
    await tester.enterText(find.byType(TextFormField).at(2), '3');
    await tester.tap(find.text('Simpan Buku'));
    await tester.pumpAndSettle();
    expect(find.text('Buku Tes'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit buku').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Buku Tes Edit');
    await tester.tap(find.text('Simpan Buku'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Buku Tes Edit');
    await tester.pumpAndSettle();
    expect(find.text('Buku Tes Edit'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Hapus buku').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('Buku Tes Edit'), findsNothing);
  });

  testWidgets('catalog and profile forms fit a phone screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());
    await tester.tap(find.byTooltip('Buka menu navigasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Katalog Buku').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Buku'));
    await tester.pumpAndSettle();

    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Kondisi Buku'), findsOneWidget);
    final dialogDecorators = tester.widgetList<InputDecorator>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(InputDecorator),
      ),
    );
    for (final decorator in dialogDecorators) {
      expect(decorator.decoration.labelText, isNull);
      expect(decorator.decoration.hintText, isNotNull);
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Buka menu navigasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('ID Admin'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history, violations, and profile pages open from navbar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PustakaKuAdminApp());

    await tester.tap(find.text('Riwayat').first);
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Aktivitas'), findsOneWidget);
    expect(find.text('Pembatalan Peminjaman'), findsOneWidget);

    await tester.tap(find.text('Pelanggaran').first);
    await tester.pumpAndSettle();
    expect(find.text('Daftar Pelanggaran'), findsOneWidget);

    await tester.tap(find.text('Profil').first);
    await tester.pumpAndSettle();
    expect(find.text('Profil Admin'), findsOneWidget);
    await tester.tap(find.text('Edit Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });
}
