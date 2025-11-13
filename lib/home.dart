import 'package:saferide/app_import.dart';
import 'package:saferide/map.dart';
import 'package:saferide/reward.dart';
import 'package:saferide/use_history.dart';
import 'package:saferide/my_page.dart';
import 'package:saferide/bottom_nav_bar.dart';
import 'package:saferide/nav_stat.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  // 로그인 위젯 State 객체
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    MapView(),
    Reward(),
    UseHistory(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavState(),
      child: Scaffold(
        body: Consumer<NavState>(
          builder: (context, navState, child) {
            return _screens[navState.selectedIndex];
          },
        ),
        bottomNavigationBar: Consumer<NavState>(
          builder: (context, navState, child) {
            return BottomNavBar(
              curIndex: navState.selectedIndex,
              onTap: (index) {
                navState.setSelectedIndex(index);
              }
            );
          },
        ),
      ),
    );
  }
}