import 'package:saferide/app_import.dart';
import 'package:saferide/style.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _pwC = TextEditingController();
  final _pwCheckC = TextEditingController();
  bool _pwObscure = true;
  bool _pwCheckObscure = true;

  bool _afterOCR = false;
  bool _afterVerify = false;

  bool _lcVerified = false;
  String _extractedText = '';
  String? lcNumber;
  String? lcName;
  String? lcBirth;
  final _lcNumberC = TextEditingController();
  final _lcNameC = TextEditingController();
  final _lcBirthC = TextEditingController();
  String _verifiedMessage = '';

  bool _imgLoading = false;
  bool _verifyLoading = false;

  Future<void> _pickLicenseImage(ImageSource src) async {
    if(_imgLoading) return;

    setState(() {
      _imgLoading = true;
    });

    ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: src);

    if(pickedFile == null) return;

    setState(() {
      _afterOCR = true;
      _imgLoading = false;
    });

    await _extractText(File(pickedFile.path));
  }

  Future<void> _extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
      });

      _parseLicenseInfo(_extractedText);

      _lcNumberC.text = lcNumber ?? '';
      _lcNameC.text = lcName ?? '';
      _lcBirthC.text = lcBirth ?? '';
    } catch (e) {
      debugPrint('Failed to recognize text: $e');
    } finally {
      textRecognizer.close();
    }
  }

  void _parseLicenseInfo(String text) {
    final ignoreWords = [
      '운전면허증',
      '자동차운전면허증',
      '종보통',
      '종대형',
      '원동기'
    ];

    final lines = text
        .split('\n')
        .map((e) => e
        .replaceAll(RegExp(r'[\s\u200B-\u200F\uFEFF]'), '')
        .trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final lcNumberRegex = RegExp(r'\d{2}-\d{2}-\d{6}-\d{2}');
    final nameRegex = RegExp(r'^[\uac00-\ud7a3]{2,4}$');
    final birthRegex = RegExp(r'\b(\d{6})-\d{7}\b');

    for(int i=0; i<lines.length; i++){
      final line = lines[i];

      if(ignoreWords.any((word) => line.contains(word))) continue;

      if(lcNumber == null && lcNumberRegex.hasMatch(line)){
        lcNumber = lcNumberRegex.firstMatch(line)!.group(0);
      }

      if(lcName == null && nameRegex.hasMatch(line)){
        lcName = nameRegex.firstMatch(line)!.group(0);
      }

      if(lcBirth == null && birthRegex.hasMatch(line)){
        lcBirth = birthRegex.firstMatch(line)!.group(1);
      }
    }

    debugPrint('면허번호: $lcNumber');
    debugPrint('이름: $lcName');
    debugPrint('생년월일: $lcBirth');

    setState(() {
      _afterOCR = true;
    });
  }

  Widget _lcImageUploadBox() {
    return DottedBorder(
      options: RectDottedBorderOptions(
        color: Colors.grey,
        strokeWidth: 2.0,
        dashPattern: [6, 3],
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.upload_outlined,
              size: 48.0,
              color: Colors.grey,
            ),

            SizedBox(height: 12.0),

            simpleText(
              '면허증을 촬영하거나 선택해주세요',
              14.0, FontWeight.normal, Colors.grey, TextAlign.center
            ),

            SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              height: 42.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () => _pickLicenseImage(ImageSource.camera),
                child: simpleText(
                  '사진 촬영하기',
                  16.0, FontWeight.normal, Colors.white, TextAlign.center
                ),
              ),
            ),

            SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              height: 42.0,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () => _pickLicenseImage(ImageSource.gallery),
                child: simpleText(
                  '파일에서 선택하기',
                  16.0, FontWeight.normal, Colors.black, TextAlign.center
                ),
              ),
            ),

            SizedBox(height: 8.0),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.image_outlined, size: 14.0, color: Colors.grey),
                SizedBox(width: 2.0),
                Text('이미지 인식', style: TextStyle(fontSize: 10.0)),
                SizedBox(width: 4.0),
                Icon(Icons.text_snippet_outlined, size: 14.0, color: Colors.grey),
                SizedBox(width: 2.0),
                Text('텍스트 추출', style: TextStyle(fontSize: 10.0)),
                SizedBox(width: 4.0),
                Icon(Icons.verified_user_outlined, size: 14.0, color: Colors.grey),
                SizedBox(width: 2.0),
                Text('유효성 검증', style: TextStyle(fontSize: 10.0)),
              ],
            )
          ],
        )
      ),
    );
  }

  Widget _verifyBox() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _licenseTextField('면허증 번호', _lcNumberC),
          SizedBox(height: 8.0),
          _licenseTextField('이름', _lcNameC),
          SizedBox(height: 8.0),
          _licenseTextField('생년월일', _lcBirthC),
          SizedBox(height: 16.0),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              label: Text('면허증 검증'),
              icon: Icon(Icons.verified_user_outlined),
              onPressed: verifySubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        simpleText(
          label,
          16.0, FontWeight.normal, Colors.black, TextAlign.start
        ),

        SizedBox(height: 4.0),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
        ),
      ],
    );
  }

  void verifySubmit() async {
    if(_verifyLoading) return;

    setState(() {
      _verifyLoading = true;
    });

    final lcNumber = _lcNumberC.text.trim();
    final name = _lcNameC.text.trim();
    final birth = _lcBirthC.text.trim();

    if(lcNumber.isEmpty || name.isEmpty || birth.isEmpty) return;

    final verifyRes = await verifyLicense(lcNumber: lcNumber, name: name, birth: birth);

    setState(() {
      _lcVerified = verifyRes;

      if(verifyRes){
        _verifiedMessage = '면허증 검증 성공';
      } else{
        _verifiedMessage = '면허증 검증 실패';
      }

      _verifyLoading = false;
      _afterVerify = true;
    });
  }

  Future<bool> verifyLicense({
    required String lcNumber,
    required String name,
    required String birth,
  }) async {
    try {
      final res = await SupabaseManager.client
          .from('license_verify_test')
          .select('*')
          .eq('lcNumber', lcNumber)
          .eq('name', name)
          .eq('birth', birth)
          .limit(1);

      if(res.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  Widget _verifiedResultBox() {
    final icon = _lcVerified ? Icons.check_circle : Icons.error;
    final iconColor = _lcVerified ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 64.0, color: iconColor),
                SizedBox(height: 12.0),

                simpleText(
                  _verifiedMessage,
                  18.0, FontWeight.bold, Colors.black, TextAlign.center
                ),
                SizedBox(height: 12.0),

                if(_lcVerified) ...[
                  _verifiedResultRow('면허증 번호', _lcNumberC.text.trim()),
                  _verifiedResultRow('이름', _lcNameC.text.trim()),
                  _verifiedResultRow('생년월일', _lcBirthC.text.trim()),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _verifiedResultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 84.0,
          child: simpleText(
            label,
            12.0, FontWeight.normal, Colors.black, TextAlign.start
          ),
        ),

        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: simpleText(
              value.isEmpty ? '-' : value,
              14.0, FontWeight.normal, Colors.black, TextAlign.start
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: simpleText(
              '1/2',
              12.0, FontWeight.bold, Colors.black, TextAlign.end
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ClipRect(
              child: LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
                minHeight: 6,
              ),
            ),

            SizedBox(height: 24.0),

            simpleText(
              '계정 생성하기',
              24.0, FontWeight.bold, Colors.black, TextAlign.center
            ),

            SizedBox(height: 8.0),

            simpleText(
              '기본 정보와 운전면허증을 등록해주세요',
              16.0, FontWeight.normal, Colors.black, TextAlign.center
            ),

            SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(),
                      ),
                      child: Form(
                        key: _signUpFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            inputLabel('이름'),
                            TextFormField(
                              controller: _nameC,
                              decoration: inputDeco('홍길동'),
                              validator: (v) => (v == null || v.isEmpty)
                                ? '이름을 입력하세요'
                                : null,
                            ),

                            SizedBox(height: 8.0),

                            inputLabel('이메일'),
                            TextFormField(
                              controller: _emailC,
                              decoration: inputDeco('example@email.com'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || !v.contains('@'))
                                ? '올바른 이메일을 입력하세요'
                                : null,
                            ),

                            SizedBox(height: 8.0),

                            inputLabel('전화번호'),
                            TextFormField(
                              controller: _phoneC,
                              decoration: inputDeco('010-1234-5678'),
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.length < 13)
                                ? '전화번호를 입력하세요'
                                : null,
                            ),

                            SizedBox(height: 8.0),

                            inputLabel('비밀번호'),
                            TextFormField(
                              controller: _pwC,
                              obscureText: _pwObscure,
                              decoration: inputDeco('비밀번호 (최소 6자)').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_pwObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined
                                  ),
                                  onPressed: () => setState(() => _pwObscure = !_pwObscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                ? '6자 이상 입력하세요'
                                : null
                            ),

                            SizedBox(height: 8.0),

                            inputLabel('비밀번호 확인'),
                            TextFormField(
                              controller: _pwCheckC,
                              obscureText: _pwCheckObscure,
                              decoration: inputDeco('비밀번호를 다시 입력하세요').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_pwCheckObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined
                                  ),
                                  onPressed: () => setState(() => _pwCheckObscure = !_pwCheckObscure),
                                ),
                              ),
                              validator: (v) => (v != _pwC.text)
                                ? '비밀번호가 일치하지 않습니다'
                                : null,
                            ),

                            SizedBox(height: 32),

                            simpleText(
                              '운전면허증 등록',
                              24.0, FontWeight.bold, Colors.black, TextAlign.center
                            ),

                            SizedBox(height: 12.0),

                            simpleText(
                              '안전한 킥보드 이용을 위해\n운전면허증을 등록해주세요',
                              16.0, FontWeight.normal, Colors.black, TextAlign.center
                            ),

                            SizedBox(height: 16.0),

                            if(!_afterVerify)
                              _afterOCR ? _verifyBox() : _lcImageUploadBox()
                            else
                              _verifiedResultBox(),

                            SizedBox(height: 16.0),

                            SizedBox(
                              width: double.infinity,
                              height: 48.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                onPressed: () {
                                  debugPrint('Sign Up');
                                },
                                child: simpleText(
                                  '회원가입',
                                  20.0, FontWeight.bold, Colors.white, TextAlign.start
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  )
                ]
              )
            )
          ],
        )
      ),
    );
  }
}