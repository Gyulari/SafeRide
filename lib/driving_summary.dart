import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';
import 'package:intl/intl.dart';

class DrivingSummaryScreen extends StatelessWidget {
  final int deviceNumber;
  final Duration elapsed;
  final int charge;

  const DrivingSummaryScreen({
    super.key,
    required this.deviceNumber,
    required this.elapsed,
    required this.charge,
  });

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}분 ${two(d.inSeconds % 60)}초';
  }

  @override
  Widget build(BuildContext context) {
    final seconds = elapsed.inSeconds;
    final estimateMeters = seconds * 2.5;
    final estimatedKm = estimateMeters / 1000;

    final minutes = (seconds / 60).ceil();
    final baseCharge = minutes * charge;

    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[700],
        flexibleSpace: FlexibleSpaceBar(
          title: simpleText(
              '주행 종료',
              24.0, FontWeight.bold, Colors.white, TextAlign.start
          ),
          titlePadding: EdgeInsetsDirectional.only(start: 64.0, bottom: 16.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48.0,
                  ),

                  SizedBox(height: 8.0),

                  simpleText(
                    '주행 요약',
                    20.0, FontWeight.bold, Colors.black, TextAlign.center
                  ),

                  SizedBox(height: 8.0),

                  simpleText(
                    '스쿠터 #$deviceNumber 이용 완료',
                    16.0, FontWeight.normal, Colors.black, TextAlign.center
                  ),

                  SizedBox(height: 16.0),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time, color: Colors.black54),
                              SizedBox(height: 6.0),
                              simpleText(
                                '${elapsed.inMinutes}분 ${elapsed.inSeconds % 60}초',
                                18.0, FontWeight.bold, Colors.black, TextAlign.center
                              ),
                              SizedBox(height: 4.0),
                              simpleText(
                                '정확한 이용 시간',
                                16.0, FontWeight.normal, Colors.black, TextAlign.center
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 8.0),

                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.place_outlined, color: Colors.black54),
                              SizedBox(height: 6.0),
                              simpleText(
                                '${estimatedKm.toStringAsFixed(2)}km',
                                18.0, FontWeight.bold, Colors.black, TextAlign.center
                              ),
                              SizedBox(height: 4.0),
                              simpleText(
                                '예상 이동 거리',
                                16.0, FontWeight.normal, Colors.black, TextAlign.center
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 16.0),

                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.emoji_events_outlined, color: Colors.green),
                            SizedBox(width: 8.0),
                            simpleText(
                              '안전 점수',
                              18.0, FontWeight.bold, Colors.black, TextAlign.center
                            ),
                            Spacer(),
                            simpleText(
                              '100 / 100',
                              18.0, FontWeight.bold, Colors.green, TextAlign.end
                            ),
                          ],
                        ),

                        SizedBox(height: 8.0),

                        simpleText(
                          '✓ 헬멧 착용 확인 ✓ 안전 주행 ✓ 올바른 주차',
                          16.0, FontWeight.bold, Colors.green, TextAlign.start
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8.0),
                  Divider(),
                  SizedBox(height: 8.0),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          simpleText(
                            '기본 요금',
                            18.0, FontWeight.normal, Colors.black, TextAlign.start
                          ),
                          simpleText(
                            '₩${formatter.format(baseCharge)}',
                            18.0, FontWeight.normal, Colors.black, TextAlign.end
                          ),
                        ],
                      ),

                      SizedBox(height: 8.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          simpleText(
                            '헬멧 할인',
                            18.0, FontWeight.normal, Colors.green, TextAlign.start
                          ),
                          simpleText(
                            '- ₩200',
                            18.0, FontWeight.normal, Colors.green, TextAlign.start
                          ),
                        ],
                      ),

                      SizedBox(height: 8.0),
                      Divider(),
                      SizedBox(height: 8.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          simpleText(
                            '총 요금',
                            20.0, FontWeight.bold, Colors.black, TextAlign.start
                          ),
                          simpleText(
                            (baseCharge - 200 > 0)
                              ? '₩${formatter.format(baseCharge - 200)}'
                              : '₩0',
                            20.0, FontWeight.bold, Colors.black, TextAlign.end
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 20.0),
            getMileagesBox(elapsed),
            SizedBox(height: 20.0),

            SizedBox(
              height: 48.0,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: simpleText(
                  '주행 완료하기',
                  16.0, FontWeight.bold, Colors.white, TextAlign.center
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getMileagesBox(Duration elapsed) {
    if (elapsed.inMinutes >= 5) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 26.0),
        decoration: BoxDecoration(
            color: Color(0xFFFFFBEA),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFFFFE8A6)),
        ),
        child: Column(
          children: [
            Icon(Icons.bolt, color: Colors.orange, size: 40.0),
            SizedBox(height: 6.0),
            simpleText(
              '마일리지 적립!',
              18.0, FontWeight.bold, Colors.orange.shade800, TextAlign.center
            ),
            SizedBox(height: 6.0),
            simpleText(
              '+100P',
              22.0, FontWeight.bold, Colors.orange.shade700, TextAlign.center
            ),
            SizedBox(height: 6.0),
            simpleText(
              '5분 이상 안전 주행으로 마일리지가 적립되었습니다',
              12.0, FontWeight.normal, Colors.brown.shade400, TextAlign.center
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 26.0),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(Icons.schedule, color: Colors.grey, size: 40.0),
            SizedBox(height: 6.0),
            simpleText(
              '마일리지 미적립',
              18.0, FontWeight.bold, Colors.grey.shade700, TextAlign.center
            ),
            SizedBox(height: 6.0),
            simpleText(
              '0P',
              22.0, FontWeight.bold, Colors.grey, TextAlign.center
            ),
            SizedBox(height: 6.0),
            simpleText(
              '5분 이상 이용 시 마일리지가 적립됩니다',
              12.0, FontWeight.normal, Colors.grey, TextAlign.center
            ),
          ],
        ),
      );
    }
  }
}