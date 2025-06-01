import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'book.dart';
import 'package:flutter/Cupertino.dart';
import 'package:intl/intl.dart';

// 검색 후 책을 클릭했을 때 화면 (책 상세정보)
class BookDetailPage extends StatefulWidget {
  final Map book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final Box<Book> wishlistBox;
  late final Book currentBook;

  @override
  void initState() {
    super.initState();
    wishlistBox = Hive.box<Book>('wishlist');
    currentBook = mapToBook(widget.book);
  }

  bool isWishlisted() => wishlistBox.containsKey(currentBook.id);

  void toggleWishlist() {
    setState(() {
      if (isWishlisted()) {
        wishlistBox.delete(currentBook.id);
      } else {
        wishlistBox.put(currentBook.id, currentBook);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('책 상세정보'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            isWishlisted() ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color:
                isWishlisted()
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey,
          ),
          onPressed: toggleWishlist,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                book['thumbnail'] != ''
                    ? Image.network(book['thumbnail'], height: 250)
                    : Container(
                      child: Center(
                        child: Text(
                          '썸네일 없음',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      height: 250,
                    ),
                Divider(height: 32),
                Text(
                  // 제목
                  book['title'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 14),
                Text(
                  // 저자
                  book['authors'].join(', '),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  // 출판사
                  book['publisher'],
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Text(
                  // 출간일
                  DateFormat(
                    'yyyy.MM.dd',
                  ).format(DateTime.parse(book['datetime'])),
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Divider(height: 32),
                Text('${book['contents']}...'), // 책 간단소개
              ],
            ),
          ),
        ),
      ),
    );
  }
}
