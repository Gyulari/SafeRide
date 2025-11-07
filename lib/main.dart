import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';
import 'package:saferide/route_import.dart';

void main() async {
  await SupabaseManager.init();
  runApp(const SafeRide());
}

class SafeRide extends StatelessWidget {
  const SafeRide({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Ride',

      routes: {
        '/': (_) => InitialScreen(),
        '/login': (_) => LoginScreen(),
        '/login/signup': (_) => SignupScreen(),
      },
      initialRoute: '/',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,

            children: [
              // Logo Image
              Image.asset(
                'assets/logo.png',
                width: 250,
                height: 250,
                fit: BoxFit.fill,
              ),

              simpleText(
                  'Safe Ride',
                  36, FontWeight.bold, Colors.black, TextAlign.center),

              SizedBox(height: 10),

              simpleText(
                'AI 기반 전동 킥보드 안전 관리 플랫폼',
                20, FontWeight.normal, Colors.black, TextAlign.center),

              SizedBox(height: 40),

              simpleText(
                'Safe Ride로 안전하고\n스마트하게 이동하세요',
                24, FontWeight.bold, Colors.black, TextAlign.center),

              SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(0),
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  debugPrint('Move to LoginScreen');
                  Navigator.pushNamed(context, '/login');
                },
                child: simpleText(
                  '로그인',
                  20, FontWeight.bold, Colors.white, TextAlign.start),
                ),

              SizedBox(height: 40),

              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.notification_add),
                  simpleText(
                    '모든 개인정보는 안전하게 암호화되어 관리됩니다',
                    15, FontWeight.normal, Colors.black, TextAlign.start
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}