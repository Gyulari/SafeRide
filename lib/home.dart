import 'package:saferide/app_import.dart';
import 'package:saferide/map.dart';
import 'package:saferide/rental.dart';
import 'package:saferide/reward.dart';
import 'package:saferide/use_history.dart';
import 'package:saferide/my_page.dart';
import 'package:saferide/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  // 로그인 위젯 State 객체
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MapView(),
    Rental(),
    Reward(),
    UseHistory(),
    MyPage(),
  ];

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Safe Ride')),
      body: Stack(
        children: [
          _screens[_selectedIndex],
          Positioned(
            bottom: 100.0,
            left: 16.0,
            right: 16.0,
            child: Row(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        curIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}