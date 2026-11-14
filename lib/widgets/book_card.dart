import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/book.dart';
import 'book_cover.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              BookCover(book: book, width: 66, height: 92),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    Text(
                      book.author,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      book.category,
                      style: const TextStyle(
                        color: accent,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Stok tersedia: ${book.stock}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      book.stock > 0 ? 'Tersedia' : 'Tidak tersedia',
                      style: TextStyle(
                        fontSize: 12,
                        color: book.stock > 0 ? navy : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
