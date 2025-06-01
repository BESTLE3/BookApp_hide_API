import 'package:flutter/cupertino.dart';
import 'package:bookapp/bookscreen/main_screen.dart';
import 'package:bookapp/bookscreen/wishlist_screen.dart';

class UnderBar extends StatelessWidget{
  const UnderBar({super.key});

  @override
  Widget build(BuildContext context){
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_fill),
            label: '위시리스트',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return const MainScreen();
              case 1:
                return const WishlistScreen();
              default:
                return const Center(child: Text('비밀의 공간'));
            }
          },
        );
      },
    );
  }
}