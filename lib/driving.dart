import 'package:saferide/app_import.dart';
import 'package:saferide/driving_summary.dart';
import 'package:saferide/style.dart';
import 'package:saferide/provider.dart';

class DrivingStatusBar extends StatefulWidget {
  final RentalState rentalState;
  const DrivingStatusBar({required this.rentalState, super.key});

  @override
  State<DrivingStatusBar> createState() => DrivingStatusBarState();
}

class DrivingStatusBarState extends State<DrivingStatusBar> {
  late Timer timer;
  Duration elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        elapsed = DateTime.now().difference(widget.rentalState.rentalStartTime!);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  double calculateDistanceMeters(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000;

    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);

    return R * (2 * atan2(sqrt(a), sqrt(1-a)));
  }

  @override
  Widget build(BuildContext context) {
    double distanceMeters = 0;

    if(widget.rentalState.currentPosition != null && widget.rentalState.destination != null) {
      distanceMeters = calculateDistanceMeters(
        widget.rentalState.currentPosition!.latitude,
        widget.rentalState.currentPosition!.longitude,
        widget.rentalState.destination!.latitude,
        widget.rentalState.destination!.longitude,
      );
    }

    String displayDistance = (distanceMeters >= 1000)
      ? '${(distanceMeters / 1000).toStringAsFixed(2)} km'
      : '${distanceMeters.toStringAsFixed(0)} m';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFFEF0),
        border: Border.all(color: Colors.green.shade400),
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 12.0),
                  SizedBox(width: 6.0),
                  simpleText(
                    '주행 중',
                    16.0, FontWeight.bold, Colors.green.shade800, TextAlign.start
                  ),
                  SizedBox(width: 12.0),
                  Icon(Icons.ev_station_outlined, size: 16.0, color: Colors.green.shade800),
                  simpleText(
                    '배터리 ${widget.rentalState.battery}%',
                    16.0, FontWeight.bold, Colors.green.shade800, TextAlign.start
                  ),
                  SizedBox(width: 12.0),
                  Icon(Icons.route_outlined, size: 16.0, color: Colors.green.shade800),
                  simpleText(
                    displayDistance,
                    16.0, FontWeight.bold, Colors.green.shade800, TextAlign.start
                  ),
                ],
              ),

              simpleText(
                formatDuration(elapsed),
                16.0, FontWeight.bold, Colors.green.shade900, TextAlign.start
              ),
            ],
          ),

          SizedBox(height: 8.0),

          simpleText(
            '스쿠터 #${widget.rentalState.deviceNumber}',
            16.0, FontWeight.bold, Colors.green.shade900, TextAlign.start
          ),

          SizedBox(height: 10.0),

          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                final rental = widget.rentalState;
                final elapsed = DateTime.now().difference(rental.rentalStartTime!);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrivingSummaryScreen(
                      deviceNumber: rental.deviceNumber,
                      elapsed: elapsed,
                      charge: rental.charge,
                      isCouple: rental.isCouple,
                    ),
                  ),
                ).then((_) {
                  rental.endRental();
                });
              },
              child: simpleText(
                '주행 종료',
                16.0, FontWeight.bold, Colors.white, TextAlign.center
              ),
            ),
          ),
        ],
      ),
    );
  }
}