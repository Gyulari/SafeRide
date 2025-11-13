import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: simpleText(
          '이용 안내 & 안전 수칙',
          24.0, FontWeight.bold, Colors.white, TextAlign.start
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('SafeRide 안전 수칙'),
            SizedBox(height: 24.0),

            _guideCard(
              icon: Icons.error_outline,
              title: '헬멧 착용 필수',
              backgroundColor: Colors.red[50]!,
              fontColor: Colors.red,
              description: '안전을 위해 반드시 헬멧을 착용하고 주행하세요. AI가 실시간으로 확인하며, 착용 시 요금 할인 혜택을 제공합니다.',
            ),

            SizedBox(height: 20.0),

            _guideCard(
              icon: Icons.person,
              title: '1인 탑승 원칙',
              backgroundColor: Colors.blue[50]!,
              fontColor: Colors.blue,
              description: '킥보드는 1인용 이동수단입니다. AI가 2명 이상 탑승을 감지하면 자동으로 운행이 중단됩니다. 커플/가족 요금제를 이용해주세요.',
            ),

            SizedBox(height: 20.0),

            _guideCard(
              icon: Icons.place,
              title: '지정 구역 주차',
              backgroundColor: Colors.green[50]!,
              fontColor: Colors.green,
              description: '이용 완료 후 반드시 지정된 주차 구역에 주차해주세요. 올바른 주차 시 마일리지가 적립됩니다.',
            ),
            
            SizedBox(height: 36.0),
            
            sectionTitle('AI 안전 기능'),
            SizedBox(height: 24.0),
            
            _featureCard(
              icon: Icons.remove_red_eye_outlined,
              title: '실시간 안전 모니터링',
              backgroundColor: Colors.blue[50]!,
              fontColor: Colors.blue,
              descriptions: ['헬멧 착용 여부 자동 감지', '탑승 인원 실시간 확인', '비정상 주행 패턴 감지'],
            ),

            SizedBox(height: 20.0),

            _featureCard(
              icon: Icons.fingerprint,
              title: '생체 인증 시스템',
              backgroundColor: Colors.green[50]!,
              fontColor: Colors.green,
              descriptions: ['Face ID / 지문 인식 본인 확인', '운전면허증 소유자 일치 검증', '무면허 이용 원천 차단'],
            ),

            SizedBox(height:16.0),
            Divider(thickness: 2.5, height: 10.0, color: Color(0xFFE0E0E0)),
            SizedBox(height:16.0),

            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3.0,
                    color: Colors.grey.withAlpha(25),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 24.0),
                      SizedBox(width: 10.0),
                      simpleText(
                        '비상 연락처',
                        20.0, FontWeight.bold, Colors.red, TextAlign.start
                      ),
                    ],
                  ),

                  SizedBox(height: 16.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      simpleText(
                        '24시간 고객센터',
                        16.0, FontWeight.normal, Colors.black, TextAlign.start
                      ),
                      simpleText(
                        '1588-0000',
                        16.0, FontWeight.bold, Colors.black, TextAlign.end
                      ),
                    ],
                  ),

                  SizedBox(height: 8.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      simpleText(
                        '응급상황 신고',
                        16.0, FontWeight.normal, Colors.black, TextAlign.start
                      ),
                      simpleText(
                        '112 / 119',
                        16.0, FontWeight.bold, Colors.black, TextAlign.end
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _guideCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color fontColor,
    required String description,
  })
  {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: Colors.grey.withAlpha(25),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fontColor, size: 24.0),
              SizedBox(width: 10.0),
              simpleText(
                title,
                20.0, FontWeight.bold, fontColor, TextAlign.start
              ),
            ],
          ),

          SizedBox(height: 8.0),

          simpleText(
            description,
            16.0, FontWeight.normal, Colors.black, TextAlign.start
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color fontColor,
    required List<String> descriptions,
  })
  {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: Colors.grey.withAlpha(25),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fontColor, size: 24.0),
              SizedBox(width: 10.0),
              simpleText(
                title,
                18.0, FontWeight.bold, fontColor, TextAlign.start
              ),
            ],
          ),

          SizedBox(height: 12.0),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...descriptions.map((text) => _featureRow(text, fontColor)),
            ],
          )
        ],
      ),
    );
  }

  Widget _featureRow(String text, Color iconColor) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: iconColor, size: 8.0),
            SizedBox(width: 8.0),
            simpleText(
              text,
              16.0, FontWeight.normal, Colors.black, TextAlign.start
            ),
          ],
        ),
        SizedBox(height: 4.0),
      ],
    );
  }
}