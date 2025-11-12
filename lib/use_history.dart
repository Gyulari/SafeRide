import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';

class UseHistory extends StatefulWidget {
  const UseHistory({super.key});

  @override
  State<UseHistory> createState() => _UseHistoryState();
}

class _UseHistoryState extends State<UseHistory> {
  final int historyCount = 0;
  final int totalDistance = 0;
  final int earnedMileage = 0;

  @override
  Widget build(BuildContext context) {
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
                    '이용 기록',
                    24.0, FontWeight.bold, Colors.white, TextAlign.start
                ),
                titlePadding: EdgeInsetsDirectional.only(start: 32.0, bottom: 16.0),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryCard('$historyCount', '총 이용', Colors.blue[50]!, Colors.blue),
                        _summaryCard('${totalDistance}km', '총 거리', Colors.green[50]!, Colors.green),
                        _summaryCard('${earnedMileage}P', '적립 마일리지', Colors.amber[50]!, Colors.amber[700]!),
                      ],
                    ),

                    SizedBox(height: 30.0),
                    sectionTitle('최근 이용 내역'),
                    SizedBox(height: 12.0),

                    _recentUsage(
                      date: '11월 11일 오전 07:45 (34분)',
                      distance: '7.8km',
                      fee: '₩5,590',
                      tags: ['헬맷 착용', '올바른 주차'],
                      mileage: '+80 마일리지 적립',
                    ),
                    _recentUsage(
                      date: '11월 10일 오전 10:30 (39분)',
                      distance: '6.1km',
                      fee: '₩5,070',
                      tags: ['헬맷 착용', '안전 주행', '올바른 주차'],
                      mileage: '+100 마일리지 적립',
                    ),
                    _recentUsage(
                      date: '11월 9일 오후 04:10 (39분)',
                      distance: '5.9km',
                      fee: '₩5,070',
                      tags: ['안전 주행', '올바른 주차'],
                      mileage: '+50 마일리지 적립',
                    ),
                    _recentUsage(
                      date: '11월 5일 오전 07:50 (36분)',
                      distance: '6.2km',
                      fee: '₩4,680',
                      tags: ['헬맷 착용', '안전 주행', '올바른 주차'],
                      mileage: '+100 마일리지 적립',
                    ),
                  ],
                ),
              ),
            )
          ]
      ),
    );
  }

  Widget _summaryCard(String value, String label, Color backgroundColor, Color labelColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            simpleText(
              value,
              32.0, FontWeight.bold, labelColor, TextAlign.center
            ),
            SizedBox(height: 6.0),
            simpleText(
              label,
              18.0, FontWeight.bold, Colors.black, TextAlign.center
            ),
          ],
        )
      ),
    );
  }

  Widget _recentUsage({
    required String date,
    required String distance,
    required String fee,
    required List<String> tags,
    required String mileage,
  })
  {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.electric_scooter, color: Colors.blue, size: 24.0),
                  SizedBox(width: 10.0),
                  simpleText(
                    '킥보드 이용',
                    18.0, FontWeight.bold, Colors.black, TextAlign.start
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: simpleText(
                  '완료',
                  12.0, FontWeight.normal, Colors.black, TextAlign.center
                ),
              ),
            ],
          ),

          SizedBox(height: 12.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 18.0, color: Colors.grey),
                  SizedBox(width: 6.0),
                  simpleText(
                    '이용 시간',
                    15.0, FontWeight.normal, Colors.black, TextAlign.start
                  ),
                ],
              ),
              simpleText(
                date,
                15.0, FontWeight.normal, Colors.black, TextAlign.end
              ),
            ],
          ),

          SizedBox(height: 8.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.route, size: 18.0, color: Colors.grey),
                  SizedBox(width: 6.0),
                  simpleText(
                    '이동 거리',
                    15.0, FontWeight.normal, Colors.black, TextAlign.start
                  ),
                ],
              ),
              simpleText(
                distance,
                15.0, FontWeight.normal, Colors.black, TextAlign.end
              ),
            ],
          ),

          SizedBox(height: 8.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  simpleText(
                    '이용 요금',
                    15.0, FontWeight.normal, Colors.black, TextAlign.start
                  ),
                ],
              ),
              simpleText(
                fee,
                15.0, FontWeight.normal, Colors.black, TextAlign.end
              ),
            ],
          ),

          SizedBox(height: 10.0),
          Divider(height: 1.0, color: Color(0xFFE0E0E0)),
          SizedBox(height: 10.0),

          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: tags.map((t) => _tagChip(t)).toList(),
          ),

          SizedBox(height: 18.0),

          Align(
            alignment: Alignment.centerRight,
            child: simpleText(
              mileage,
              16.0, FontWeight.bold, Colors.green, TextAlign.end
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String text) {
    Color backgroundColor;
    Color fontColor;

    if(text.contains('헬멧')) {
      backgroundColor = Colors.green[50]!;
      fontColor = Colors.green;
    } else if(text.contains('안전')) {
      backgroundColor = Colors.blue[50]!;
      fontColor = Colors.blue;
    } else if(text.contains('주차')) {
      backgroundColor = Colors.amber[50]!;
      fontColor = Colors.amber[800]!;
    } else {
      backgroundColor = Colors.grey[200]!;
      fontColor = Colors.black54;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: fontColor, size: 16.0),
          SizedBox(width: 4.0),
          simpleText(
            text,
            12.0, FontWeight.bold, fontColor, TextAlign.center
          ),
        ],
      ),
    );
  }
}