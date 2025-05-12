import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 1)
class Book {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String thumbnail;

  @HiveField(4)
  final String publisher;

  @HiveField(5)
  final String datetime;

  @HiveField(6)
  final String contents;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.publisher,
    required this.datetime,
    required this.contents,
  });
}

Book mapToBook(Map json) {
  return Book(
    id: json['id'] ?? json['isbn'] ?? json['title'],
    title: json['title'],
    author: (json['authors'] as List).join(', '),
    thumbnail: json['thumbnail'] ?? '',
    publisher: json['publisher'],
    datetime: json['datetime'],
    contents: json['contents'],
  );
}
