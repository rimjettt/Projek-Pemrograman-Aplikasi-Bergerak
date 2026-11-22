import 'book.dart';

class Loan {
  final Book book;
  final String status;
  final String dueDate;
  final String borrowDate;
  final String? returnStatus;
  final String borrowerName;
  final String initialCondition;
  final String initialPhotoPath;
  final String? returnCondition;
  final String returnNotes;
  final String returnPhotoPath;

  Loan(
      this.book, {
        this.status = 'Menunggu persetujuan',
        this.dueDate = 'Ditetapkan setelah buku diserahkan',
        this.borrowDate = '',
        this.returnStatus,
        this.borrowerName = '',
        this.initialCondition = 'Baik',
        this.initialPhotoPath = '',
        this.returnCondition,
        this.returnNotes = '',
        this.returnPhotoPath = '',
      });


  Loan copyWith({
    String? returnStatus,
    String? returnCondition,
    String? returnNotes,
    String? returnPhotoPath,
  }) {
    return Loan(
      book,
      status: status,
      dueDate: dueDate,
      borrowDate: borrowDate,
      returnStatus: returnStatus ?? this.returnStatus,
      borrowerName: borrowerName,
      initialCondition: initialCondition,
      initialPhotoPath: initialPhotoPath,
      returnCondition: returnCondition ?? this.returnCondition,
      returnNotes: returnNotes ?? this.returnNotes,
      returnPhotoPath: returnPhotoPath ?? this.returnPhotoPath,
    );
  }
}
