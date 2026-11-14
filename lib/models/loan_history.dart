import 'book.dart';

class LoanHistory {
  final Book book;
  final String activity;
  final String status;
  final String date;

  const LoanHistory({
    required this.book,
    required this.activity,
    required this.status,
    required this.date,
  });
}
