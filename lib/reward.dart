import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';

class Reward extends StatefulWidget {
  const Reward({super.key});

  @override
  State<Reward> createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  final int mileage = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: Colors.amber[700],
            flexibleSpace: FlexibleSpaceBar(
              title: simpleText(
                '리워드 & 마일리지',
                24.0, FontWeight.bold, Colors.white, TextAlign.start
              ),
              titlePadding: EdgeInsetsDirectional.only(start: 32.0, bottom: 16.0),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        simpleText(
                          '${mileage}P',
                          42.0, FontWeight.bold, Colors.white, TextAlign.center
                        ),
                        SizedBox(height: 6.0),
                        simpleText(
                          '보유 마일리지',
                          21.0, FontWeight.bold, Colors.white70, TextAlign.center
                        ),
                        SizedBox(height: 4.0),
                        simpleText(
                          '₩1250 상당 (1P = 1₩)',
                          18.0, FontWeight.bold, Colors.white70, TextAlign.center
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.0),

                  _sectionTitle('마일리지 적립 방법'),
                  SizedBox(height: 8.0),
                  _rewardMethod('헬맷 착용 주행', '주행 완료 시', '+50P', Colors.green, Icons.shield_outlined),
                  _rewardMethod('지정 주차 구역 반납', '올바른 주차 시', '+30P', Colors.blue, Icons.place_outlined),
                  _rewardMethod('1일 안전 주행', '다칠만한 일 없음', '+20P', Colors.purple, Icons.person_outlined),

                  SizedBox(height: 36.0),

                  _sectionTitle('최근 적립 내역'),
                  SizedBox(height: 8.0),
                  _recentAccrual('헬맷 착용 주행 완료', '1월 15일 오후 11:30', '+50P'),
                  _recentAccrual('지정 구역 주차 완료', '1월 15일 오후 11:25', '+30P'),
                  _recentAccrual('안전 1일 주행 완료', '1월 15일 오후 11:25', '+20P'),

                  SizedBox(height: 36.0),

                  SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {},
                      child: simpleText(
                        '마일리지 사용하기',
                        20.0, FontWeight.bold, Colors.white, TextAlign.center
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ]
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: simpleText(
        title,
        24.0, FontWeight.bold, Colors.black, TextAlign.start
      ),
    );
  }

  Widget _rewardMethod(String title, String description, String point, MaterialColor backgroundColor, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor[50],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: backgroundColor[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: backgroundColor[700],
              size: 24.0,
            ),
          ),

          SizedBox(width: 16.0),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                simpleText(
                  title,
                  18.0, FontWeight.bold, Colors.black, TextAlign.start
                ),
                SizedBox(height: 4.0),
                simpleText(
                  description,
                  16.0, FontWeight.normal, Colors.black, TextAlign.start
                ),
              ],
            ),
          ),

          simpleText(
            point,
            20.0, FontWeight.bold, backgroundColor, TextAlign.end
          ),
        ],
      )
    );
  }

  Widget _recentAccrual(String title, String date, String point) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  simpleText(
                    title,
                    18.0, FontWeight.normal, Colors.black, TextAlign.start
                  ),
                  SizedBox(height: 1.0),
                  simpleText(
                    date,
                    16.0, FontWeight.normal, Colors.black, TextAlign.start
                  ),
                ],
              ),
              simpleText(
                point,
                20.0, FontWeight.bold, Colors.green, TextAlign.end
              ),
            ],
          ),
        ),

        Divider(
          color: Colors.grey.withAlpha(100),
          thickness: 0.8,
          height: 0.0,
        )
      ],
    );
  }
}