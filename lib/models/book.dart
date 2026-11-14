class Book {
  final int id;
  final String title;
  final String author;
  final String category;
  final String coverUrl;
  final String isbn;
  final String year;
  final String publisher;
  final String description;
  int stock;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.stock,
    required this.coverUrl,
    required this.isbn,
    required this.year,
    required this.publisher,
    required this.description,
  });
}
