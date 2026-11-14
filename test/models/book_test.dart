import 'package:flutter_test/flutter_test.dart';
import 'package:pustakaku_flutter/models/book.dart';

void main() {
  test('Book menyimpan data buku dengan benar', () {
    final book = Book(
      id: 1,
      title: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Pemrograman',
      stock: 3,
      coverUrl: 'https://example.com/cover.jpg',
      isbn: '9780132350884',
      year: '2008',
      publisher: 'Prentice Hall',
      description: 'Buku tentang penulisan kode yang baik.',
    );

    expect(book.id, 1);
    expect(book.title, 'Clean Code');
    expect(book.stock, 3);
  });
}
