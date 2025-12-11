import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[700],
        flexibleSpace: FlexibleSpaceBar(
          title: simpleText(
            '결제 기록',
            24.0, FontWeight.bold, Colors.white, TextAlign.start
          ),
          titlePadding: EdgeInsetsDirectional.only(start: 60.0, bottom: 16.0),
        ),
      ),
      body: Container(),
    );
  }
}