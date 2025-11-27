import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';
import 'package:intl/intl.dart';

class UseHistory extends StatefulWidget {
  const UseHistory({super.key});

  @override
  State<UseHistory> createState() => _UseHistoryState();
}

class _UseHistoryState extends State<UseHistory> {
  int historyCount = 0;
  double totalDistance = 0;
  int accumulatedMileage = 0;

  List<Map<String, dynamic>> recentUseHistory = [];

  bool fetchLoading = false;

  Future<void> fetchUseHistoryRecord() async {
    setState(() {
      fetchLoading = true;
    });

    final user = SupabaseManager.client.auth.currentUser;
    if(user == null) {
      setState(() {
        fetchLoading = false;
      });
      return;
    }

    final res = await SupabaseManager.client
        .from('user_record')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if(res == null){
      setState(() {
        fetchLoading = false;
      });
      return;
    }

    setState(() {
      historyCount = res['total_count'] as int;
      totalDistance = res['total_distance'] as double;
      accumulatedMileage = res['accumulated_mileage'] as int;
      fetchLoading = false;
    });
  }

  Future<void> fetchUseHistory() async {
    setState(() {
      fetchLoading = true;
    });

    final user = SupabaseManager.client.auth.currentUser;

    if(user == null) {
      setState(() {
        fetchLoading = false;
      });
      return;
    }

    final rows = await SupabaseManager.client
        .from('user_use_history')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(20);

    setState(() {
      recentUseHistory = List<Map<String, dynamic>>.from(rows);
      fetchLoading = false;
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
    fetchUseHistoryRecord();
    fetchUseHistory();
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
                        _summaryCard('$historyCount', '총 이용', Colors.blue[50]!, Colors.blue, fetchLoading),
                        _summaryCard('${totalDistance.toStringAsFixed(2)}km', '총 거리', Colors.green[50]!, Colors.green, fetchLoading),
                        _summaryCard('${accumulatedMileage}P', '적립 마일리지', Colors.amber[50]!, Colors.amber[700]!, fetchLoading),
                      ],
                    ),

                    SizedBox(height: 30.0),
                    sectionTitle('최근 이용 내역'),
                    SizedBox(height: 8.0),

                    if(fetchLoading)
                      Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent),
                      )
                    else
                      if(recentUseHistory.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: simpleText(
                            '최근 이용 내역이 없습니다',
                            18.0, FontWeight.w500, Colors.grey, TextAlign.start
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: recentUseHistory.length,
                          itemBuilder: (context, index) {
                            final item = recentUseHistory[index];
                            final createdAt = DateTime.parse(item['created_at']).toLocal();
                            final elapsed = int.parse(item['elapsed'].split(':')[1]);

                            return _recentUsage(
                              date: '${formatKoreanTime(createdAt)} (약 $elapsed분)',
                              distance: '${item['distance'].toStringAsFixed(2)}km',
                              fee: '₩${NumberFormat('#,###').format(item['charge'])}',
                              tags: List<String>.from(item['compliance']),
                              mileage: '+${item['mileage']} 마일리지 적립'
                            );
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

  Widget _summaryCard(String value, String label, Color backgroundColor, Color labelColor, bool isFetching) {
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
              (isFetching) ? '-' : value,
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