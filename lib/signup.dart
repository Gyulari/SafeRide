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