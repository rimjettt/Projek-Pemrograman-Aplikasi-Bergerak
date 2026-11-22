import 'book.dart';


class LoanHistory {
  final Book book;
  final String activity;
  final String status;
  final String date;
  final String? condition;
  final String? notes;
  final String? photoPath;

  const LoanHistory({
    required this.book,
    required this.activity,
    required this.status,
    required this.date,
    this.condition,
    this.notes,
    this.photoPath,
  });
}
