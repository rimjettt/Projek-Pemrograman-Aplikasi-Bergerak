/// Menghasilkan tanggal seperti format Kotlin:
/// dd MMMM yyyy, HH:mm dengan nama bulan Bahasa Indonesia.
String formatCurrentDate() {
  final now = DateTime.now();
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final day = now.day.toString().padLeft(2, '0');
  final month = months[now.month - 1];
  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');

  return '$day $month ${now.year}, $hour:$minute';
}
