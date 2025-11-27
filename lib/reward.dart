import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';

class Reward extends StatefulWidget {
  const Reward({super.key});

  @override
  State<Reward> createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  int? mileage;

  List<Map<String, dynamic>> recentMileageLogs = [];

  Future<void> fetchMileage() async {
    final user = SupabaseManager.client.auth.currentUser;
    if(user == null) return;

    final res = await SupabaseManager.client
        .from('user_mileages')
        .select('mileage')
        .eq('user_id', user.id)
        .maybeSingle();

    if(res == null) return;

    setState(() {
      mileage = res['mileage'] as int;
    });
  }

  Future<void> fetchRecentMileageLogs() async {
    final user = SupabaseManager.client.auth.currentUser;
    if(user == null) return;

    final rows = await SupabaseManager.client
        .from('user_mileages_log')
        .select()
        .eq('user_id', user.id)
        .order('updated_at', ascending: false)
        .limit(20);

    setState(() {
      recentMileageLogs = List<Map<String, dynamic>>.from(rows);
    });
  }

  String formatKoreanTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '${dt.year}년 ${dt.month}월 ${dt.day}일 $period $displayHour시 $minute분';
  }

  @override
  void initState() {
    fetchMileage();
    fetchRecentMileageLogs();
    super.initState();
  }

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
                        mileage == null
                          ? CircularProgressIndicator(color: Colors.white)
                          : simpleText(
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
                          mileage == null
                            ? '-'
                            : '₩$mileage 상당 (1P = 1₩)',
                          18.0, FontWeight.bold, Colors.white70, TextAlign.center
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.0),

                  sectionTitle('마일리지 적립 방법'),
                  SizedBox(height: 8.0),
                  _rewardMethod('헬맷 착용 주행', '주행 완료 시', '+50P', Colors.green, Icons.shield_outlined),
                  _rewardMethod('지정 주차 구역 반납', '올바른 주차 시', '+30P', Colors.blue, Icons.place_outlined),
                  _rewardMethod('1일 안전 주행', '다칠만한 일 없음', '+20P', Colors.purple, Icons.person_outlined),

                  SizedBox(height: 36.0),

                  sectionTitle('최근 적립 내역'),
                  SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recentMileageLogs.length,
                    itemBuilder: (context, index) {
                      final item = recentMileageLogs[index];

                      final reason = item['reason'] as String;
                      final mileage = item['mileage'] as int;
                      final updatedAt = DateTime.parse(item['updated_at']).toLocal();
                      
                      return _recentAccrual(reason, formatKoreanTime(updatedAt), mileage);
                    },
                  ),
                  SizedBox(height: 36.0),
                ],
              ),
            ),
          )
        ]
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

  Widget _recentAccrual(String title, String date, int point) {
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
                '+ ${point}P',
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