import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';
import 'package:intl/intl.dart';
import 'package:saferide/provider.dart';

enum HelmetCheckStatus {
  idle,
  checking,
  success,
  fail,
}

class RentalScreen extends StatefulWidget {
  final Device device;

  const RentalScreen({super.key, required this.device});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  late Device device;

  HelmetCheckStatus hcStatus = HelmetCheckStatus.idle;
  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;
  Timer? _timer;
  int _checkingSeconds = 3;

  int finalCharge = 0;
  bool isUsingMileage = false;

  @override
  void initState() {
    super.initState();

    device = widget.device;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startHelmetCheck() async {
    if(hcStatus == HelmetCheckStatus.checking) return;

    setState(() {
      hcStatus = HelmetCheckStatus.checking;
      _checkingSeconds = 3;
    });

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
    );

    _cameraController?.dispose();
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _cameraInitFuture = _cameraController!.initialize();
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if(!mounted) return;
      setState(() {
        _checkingSeconds--;
      });

      if(_checkingSeconds <= 0) {
        timer.cancel();
        await _onTimeFinished();
      }
    });
  }

  Future<void> _onTimeFinished() async {
    try {
      await _cameraInitFuture;
      final image = await _cameraController!.takePicture();
      final bool result = await _testHelmetRecognition(image);

      if(!mounted) return;
      setState(() {
        hcStatus = result ? HelmetCheckStatus.success : HelmetCheckStatus.fail;
      });
    } catch (e) {
      if(!mounted) return;
      setState(() {
        hcStatus = HelmetCheckStatus.fail;
      });
    }
  }

  Future<bool> _testHelmetRecognition(XFile image) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Random().nextBool();
  }

  void _reset() {
    _timer?.cancel();
    _cameraController?.dispose();
    _cameraController = null;
    _cameraInitFuture = null;

    setState(() {
      hcStatus = HelmetCheckStatus.idle;
      _checkingSeconds = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    finalCharge = device.price * 10
        - ((hcStatus == HelmetCheckStatus.success) ? 200 : 0)
        - (isUsingMileage ? 1000 : 0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[700],
        flexibleSpace: FlexibleSpaceBar(
          title: simpleText(
            '대여하기',
            24.0, FontWeight.bold, Colors.white, TextAlign.start
          ),
          titlePadding: EdgeInsetsDirectional.only(start: 64.0, bottom: 16.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            sectionTitle('AI 안전 확인'),
            SizedBox(height: 24.0),
            _helmetCheckCard(),
            _deviationDetectCard(),
            _priceInfoCard(device.price),
            _paymentMethodCard(finalCharge),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Provider.of<RentalState>(context, listen: false)
                      .startRental(device.dNumber, device.battery, device.price);

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );

                    Fluttertoast.showToast(
                      msg: '킥보드 대여 시작\n결제로 ₩${NumberFormat('#,###').format(finalCharge)} 결제 완료. 안전한 주행하세요!',
                      gravity: ToastGravity.BOTTOM_RIGHT,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0
                    );
                  },
                  child: simpleText(
                    '킥보드 대여 시작 (₩${NumberFormat('#,###').format(finalCharge)})',
                    16.0, FontWeight.bold, Colors.white, TextAlign.center
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _helmetCheckCard() {
    return SectionCard(
      title: '헬멧 착용 확인',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildCameraArea(context)),
            SizedBox(height: 16.0),

            Center(
              child: simpleText(
                hcStatus == HelmetCheckStatus.checking
                  ? '헬멧을 착용하고 카메라를 바라봐주세요 ($_checkingSeconds)'
                  : hcStatus == HelmetCheckStatus.success
                    ? '인식 성공! 헬멧이 올바르게 감지되었습니다.'
                    : hcStatus == HelmetCheckStatus.fail
                      ? '인식 실패... 헬멧이 잘 보이도록 다시 시도해주세요.'
                      : '헬멧을 착용하고 버튼을 눌러 확인을 시작하세요.',
                  16.0, FontWeight.bold, Colors.grey.shade700, TextAlign.center
              ),
            ),
            SizedBox(height: 16.0),

            Center(
              child: _buildHelmetButton(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCameraArea(BuildContext context) {
    if(hcStatus == HelmetCheckStatus.idle) {
      return Container(
        width: 260.0,
        height: 180.0,
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: 40.0,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      width: 350.0,
      height: 240.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if(_cameraController != null && (hcStatus == HelmetCheckStatus.checking))
              FutureBuilder(
                future: _cameraInitFuture,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_cameraController!);
                  }
                  return Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  );
                },
              )
            else
              Container(color: Colors.black),

            Positioned(
              top: 8.0,
              left: 12.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: simpleText(
                  '카메라 활성화',
                  11.0, FontWeight.normal, Colors.white, TextAlign.start
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 12.0,
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 12.0, color: Colors.redAccent),
                  SizedBox(width: 4.0),
                  simpleText(
                    'REC',
                    11.0, FontWeight.normal, Colors.white, TextAlign.start
                  ),
                ],
              ),
            ),

            if(hcStatus == HelmetCheckStatus.success || hcStatus == HelmetCheckStatus.fail)
              Container(
                color: Colors.black.withAlpha(100),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hcStatus == HelmetCheckStatus.success
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                        size: 40.0,
                        color: hcStatus == HelmetCheckStatus.success
                          ? Colors.lightGreenAccent
                          : Colors.redAccent,
                      ),
                      SizedBox(height: 8.0),
                      simpleText(
                        hcStatus == HelmetCheckStatus.success
                          ? '인식 성공'
                          : '인식 실패',
                        16.0, FontWeight.w700, Colors.white, TextAlign.start
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildHelmetButton(BuildContext context) {
    if(hcStatus == HelmetCheckStatus.idle) {
      return ElevatedButton.icon(
        onPressed: _startHelmetCheck,
        icon: Icon(Icons.camera_alt_outlined, size: 18.0),
        label: Text('헬멧 착용 확인하기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          child: simpleText(
            '취소',
            16.0, FontWeight.bold, Colors.white, TextAlign.center
          ),
        ),

        SizedBox(width: 8.0),

        if(hcStatus != HelmetCheckStatus.checking)
          ElevatedButton(
            onPressed: _startHelmetCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: simpleText(
              '다시 시도',
              16.0, FontWeight.bold, Colors.white, TextAlign.center
            ),
          ),
      ],
    );
  }

  Widget _deviationDetectCard() {
    return SectionCard(
      title: '탑승 중 일탈 감지',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          simpleText(
            '주행 중 실시간으로 탑승 인원을 모니터링합니다.',
            13.0, FontWeight.bold, Colors.black, TextAlign.start
          ),
          SizedBox(height: 12.0),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Color(0xFFFFF5D7),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18.0,
                  color: Color(0xFFF39C12),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: simpleText(
                    '2명 이상 탑승 시 자동으로 운행이 중단됩니다.',
                    13.0, FontWeight.normal, Colors.orange.shade800, TextAlign.start
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _priceInfoCard(int price) {
    int basePrice = price * 10;
    int totalPrice = price * 10;
    bool hasHelmet = false;

    if(hcStatus == HelmetCheckStatus.success) {
      hasHelmet = true;
      totalPrice -= 200;
    }

    return SectionCard(
      title: '요금 정보',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPriceRow('기본 요금', '₩${NumberFormat('#,###').format(basePrice)}'),
          SizedBox(height: 8.0),

          if(hasHelmet)
            _buildPriceRow('헬멧 착용 할인', '- ₩${NumberFormat('#,###').format(200)}', isDiscount: true),

          Divider(height: 16.0),
          _buildPriceRow('총 결제 금액', '₩${NumberFormat('#,###').format(totalPrice)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {
    bool isTotal = false,
    bool isDiscount = false,
  })
  {
    final baseTextStyle = TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade800,
    );

    final totalPriceStyle = TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2F80FF),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
              ? baseTextStyle.copyWith(fontWeight: FontWeight.w600)
              : isDiscount
                ? baseTextStyle.copyWith(color: Colors.green)
                : baseTextStyle,
          ),
        ),
        Text(
          value,
          style: isTotal
            ? totalPriceStyle
            : isDiscount
              ? baseTextStyle.copyWith(color: Colors.green)
              : baseTextStyle,
        ),
      ],
    );
  }

  Widget _paymentMethodCard(int finalCharge) {
    return SectionCard(
      title: '결제 방법',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 32.0,
                color: Colors.yellow[700],
              ),

              SizedBox(width: 10.0),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    simpleText(
                      '마일리지 사용 (1P → 1원)',
                      14.0, FontWeight.w600, Colors.black, TextAlign.start
                    ),
                    SizedBox(height: 2.0),
                    simpleText(
                      isUsingMileage
                        ? '보유 : 150P'
                        : '보유 : 150P | 필요 : ${NumberFormat('#,###').format(finalCharge)}P',
                      12.0, FontWeight.normal, Colors.grey, TextAlign.start
                    ),
                  ],
                ),
              ),

              Switch(
                value: isUsingMileage,
                onChanged: (v) {
                  setState(() {
                    isUsingMileage = v;
                  });
                }
              ),
            ],
          ),

          SizedBox(height: 12.0),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: simpleText(
              '일반 결제 : ₩${NumberFormat('#,###').format(finalCharge)}',
              13.0, FontWeight.w600, Color(0xFF2F80FF), TextAlign.start
            ),
          )
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            simpleText(
              title,
              16.0, FontWeight.bold, Colors.black, TextAlign.start
            ),
            SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}