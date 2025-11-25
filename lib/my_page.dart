import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';
import 'package:saferide/provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int historyCount = 0;
  int totalDistance = 0;

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserInfoState>();

    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: Colors.blue[700],
            flexibleSpace: FlexibleSpaceBar(
              title: simpleText(
                '마이페이지',
                24.0, FontWeight.bold, Colors.white, TextAlign.start
              ),
              titlePadding: EdgeInsetsDirectional.only(start: 32.0, bottom: 16.0),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileCard(userState.userName, userState.userEmail),

                  SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _usageCard('$historyCount', '총 이용 횟수', Colors.blue[50]!, Colors.blue),
                      _usageCard('${totalDistance}km', '총 주행 거리', Colors.green[50]!, Colors.green),
                    ],
                  ),

                  _menuItem(
                    icon: Icons.history,
                    text: '이용 기록',
                    onTap: () {
                      context.read<NavState>().setSelectedIndex(2);
                    }
                  ),
                  _menuItem(
                    icon: Icons.payment,
                    text: '결제 기록',
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.info_outline,
                    text: '이용 안내',
                    onTap: () {
                      Navigator.of(context).pushNamed('/home/guide');
                    },
                  ),
                  _menuItem(
                    icon: Icons.support_agent,
                    text: '고객 지원',
                    onTap: () {},
                  ),

                  SizedBox(height: 10.0),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: ListTile(
                      title: Center(
                        child: simpleText(
                          '로그아웃',
                          20.0, FontWeight.bold, Colors.red, TextAlign.center
                        ),
                      ),
                      onTap: () async {
                        await SupabaseManager.client.auth.signOut();

                        if(!context.mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false
                        );
                      }
                    ),
                  ),

                  SizedBox(height: 20.0),

                  _safetyRankBar(),
                ],
              ),
            ),
          )
        ]
      ),
    );
  }

  Widget _profileCard(String userName, String userEmail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.blueAccent,
            child: simpleText(
              userName,
              12.0, FontWeight.bold, Colors.white, TextAlign.center
            ),
          ),

          SizedBox(height: 10.0),
          simpleText(
            userName,
            24.0, FontWeight.bold, Colors.black, TextAlign.center
          ),

          SizedBox(height: 2.0),
          simpleText(
            userEmail,
            20.0, FontWeight.bold, Colors.black, TextAlign.center
          ),

          SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, color: Colors.green, size: 16.0),
              SizedBox(width: 4.0),
              simpleText(
                '인증 완료',
                16.0, FontWeight.bold, Colors.green, TextAlign.start
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _usageCard(String value, String label, Color backgroundColor, Color fontColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            simpleText(
              value,
              24.0, FontWeight.bold, fontColor, TextAlign.center
            ),
            SizedBox(height: 4.0),
            simpleText(
              label,
              18.0, FontWeight.bold, fontColor, TextAlign.center
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  })
  {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: simpleText(
          text,
          14.0, FontWeight.normal, Colors.black, TextAlign.start
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }

  Widget _safetyRankBar() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield, color: Colors.green, size: 20.0),
                  SizedBox(width: 8.0),
                  simpleText(
                    '안전 등급',
                    15.0, FontWeight.bold, Colors.green, TextAlign.center
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: simpleText(
                  '플래티넘',
                  13.0, FontWeight.bold, Colors.green, TextAlign.center
                ),
              ),
            ],
          ),

          SizedBox(height: 8.0),

          LinearProgressIndicator(
            value: 0.95,
            minHeight: 8.0,
            backgroundColor: Colors.green[100],
            color: Colors.green,
            borderRadius: BorderRadius.circular(10.0),
          ),

          SizedBox(height: 8.0),

          simpleText(
            '안전 수칙을 잘 지키고 계세요!',
            13.0, FontWeight.normal, Colors.black87, TextAlign.start
          ),
        ],
      ),
    );
  }
}