import 'book.dart';

class Loan {
  final Book book;
  final String status;
  final String dueDate;
  final String? returnStatus;

  Loan(
    this.book, {
    this.status = 'Menunggu persetujuan',
    this.dueDate = 'Ditetapkan setelah buku diserahkan',
    this.returnStatus,
  });

  Loan copyWith({String? returnStatus}) {
    return Loan(
      book,
      status: status,
      dueDate: dueDate,
      returnStatus: returnStatus ?? this.returnStatus,
    );
  }
}
