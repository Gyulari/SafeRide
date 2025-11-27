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

  Future<void> _updateMileage(List<bool> estimated) async {
    final earned = (estimated[0] ? 50 : 0) + (estimated[1] ? 30 : 0) + (estimated[2] ? 20 : 0);

    final user = SupabaseManager.client.auth.currentUser;
    if(user == null) return;

    final res = await SupabaseManager.client
        .from('user_mileages')
        .select('mileage')
        .eq('user_id', user.id)
        .maybeSingle();

    if(res == null) return;

    await SupabaseManager.client
        .from('user_mileages')
        .update({'mileage': (res['mileage'] + earned)})
        .eq('user_id', user.id);

    const reasons = ['헬멧 착용 주행 완료', '지정 구역 주차 완료', '안전 1일 주행 완료'];
    const amount = [50, 30, 20];

    for(int i=0; i<estimated.length; i++){
      if(estimated[i]) {
        await SupabaseManager.client
            .from('user_mileages_log')
            .insert({
              'user_id': user.id,
              'mileage': amount[i],
              'reason': reasons[i],
            });
      }
    }
  }

  List<bool> _estimateSafeRiding() {
    final random = Random();

    final park = random.nextInt(100) < 60 ? true : false;
    final safe = random.nextInt(100) < 85 ? true : false;

    return [true, park, safe];
  }

  String _estimatedResultString(List<bool> estimated) {
    String resultString = '';

    if(estimated[0]) resultString += '✓ 헬멧 착용 확인 ';
    if(estimated[1]) resultString += '✓ 올바른 주차';
    if(estimated[2]) resultString += '✓ 안전 주행 ';

    return resultString;
  }

  @override
  Widget build(BuildContext context) {
    final seconds = elapsed.inSeconds;
    final estimateMeters = seconds * 2.5;
    final estimatedKm = estimateMeters / 1000;

    final minutes = (seconds / 60).ceil();
    final baseCharge = minutes * charge;

    final formatter = NumberFormat('#,###');

    final List<bool> estimatedRiding = _estimateSafeRiding();
    final String safeRidingString = _estimatedResultString(estimatedRiding);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[700],
        flexibleSpace: FlexibleSpaceBar(
          title: simpleText(
            '주행 종료',
            24.0, FontWeight.bold, Colors.white, TextAlign.start
          ),
          titlePadding: EdgeInsetsDirectional.only(start: 24.0, bottom: 16.0),
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
                          safeRidingString,
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
            getMileagesBox(elapsed, estimatedRiding),
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
                  if(elapsed.inMinutes >= 5){
                    _updateMileage(estimatedRiding);
                  }

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

  Widget getMileagesBox(Duration elapsed, List<bool> estimated) {
    final earned = (estimated[0] ? 50 : 0) + (estimated[1] ? 30 : 0) + (estimated[2] ? 20 : 0);

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
              '+${earned}P',
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