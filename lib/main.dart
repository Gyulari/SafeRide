import 'package:saferide/app_import.dart';

void main() async {
  await SupabaseManager.init();
  runApp(const SafeRide());
}

Future<void> _supabaseTest() async {
  String text_1 = 'Test 1';
  String text_2 = 'Test 2';
  String text_3 = 'Test 3';

  final payload = {
    'text1': text_1,
    'text2': text_2,
    'text3': text_3,
  };

  try {
    final row = await SupabaseManager.client
        .from('Test')
        .insert(payload)
        .select()
        .single();

    debugPrint('$row');
  } catch (e) {
    debugPrint("Error: $e");
  } finally {
    debugPrint("Test Complete");
  }
}

class SafeRide extends StatelessWidget {
  const SafeRide({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Ride',

      routes: {
        '/': (_) => const SupabaseTestScreen(),
      },
      initialRoute: '/',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class SupabaseTestScreen extends StatelessWidget {
  const SupabaseTestScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _supabaseTest();
          },
          child: const Text('Test'),
        ),
      ),
    );
  }
}