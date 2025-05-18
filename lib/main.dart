import 'package:bookapp/bookscreen/under_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookapp/bookscreen/book.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'asset/config/.env');

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 책 위시리스트 하이브
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(BookAdapter());
  await Hive.openBox<Book>('wishlist');

  // 제미나이 히스토리 하이브
  // Hive.registerAdapter(ChatMessageAdapter());
  // Hive.registerAdapter(MessageSenderAdapter());
  // await Hive.openBox<ChatMessage>('message_history');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: UnderBar(),

    );
  }
}
