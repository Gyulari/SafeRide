import 'package:saferide/app_import.dart';
import 'package:saferide/map.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  // 로그인 위젯 State 객체
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Safe Ride')),
      body: Stack(
        children: [
          MapView(),
          Positioned(
            bottom: 100.0,
            left: 16.0,
            right: 16.0,
            child: Row(),
          ),
        ],
      )
    );
  }
}