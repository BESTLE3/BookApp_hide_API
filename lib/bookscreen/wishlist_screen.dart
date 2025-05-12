import 'package:bookapp/bookscreen/bookdetailpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bookapp/bookscreen/book.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late final Box<Book> wishlistBox;

  @override
  initState() {
    super.initState();
    wishlistBox = Hive.box<Book>('wishlist');
  }

  void removeWishlist(String id) {
    wishlistBox.delete(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('위시리스트')),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Book>('wishlist').listenable(),
          builder: (context, Box<Book> box, _) {
            final books = box.values.toList();

            if (books.isEmpty) {
              return Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.heart_broken, size: 100, color: CupertinoColors.systemGrey),
                    Text('위시리스트가 비어있습니다.')
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return CupertinoListTile(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  leading:
                      book.thumbnail.isNotEmpty
                          ? Image.network(
                            book.thumbnail,
                            width: 150,
                            height: 150,
                          )
                          : Icon(Icons.clear, color: Colors.grey),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: const CupertinoListTileChevron(

                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => BookDetailPage(book: bookToMap(book)),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: CupertinoColors.systemGrey2,
                height: 1,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
            );
          },
        ),
      ),
    );
  }
}

Map<String, dynamic> bookToMap(Book book) {
  return {
    'id': book.id,
    'title': book.title,
    'authors': [book.author],
    'publisher': book.publisher,
    'thumbnail': book.thumbnail,
    'datetime': book.datetime.toString(),
    'contents': book.contents,
  };
}