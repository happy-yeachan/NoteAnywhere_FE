import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 로그인 API 연동
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // 로그인 성공 처리
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        // 에러 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  // 모바일용 로그인 화면
  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 및 앱 이름
                const Icon(
                  Icons.description,
                  size: 64,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '이력서 어디서나',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '어디서든 이력서를 작성하고 관리하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                // 로그인 폼
                _buildLoginForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 데스크톱용 로그인 화면
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // 왼쪽 영역 (이미지 & 소개)
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.description,
                      size: 120,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '이력서 어디서나',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '어디서든 이력서를 작성하고 관리하세요.\n쉽고 빠르게 이력서를 만들고 공유할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // 특징 목록
                    _buildFeatureItem(Icons.edit_document, '손쉬운 이력서 작성',
                        '직관적인 인터페이스로 누구나 쉽게 이력서를 작성할 수 있습니다.'),
                    const SizedBox(height: 24),
                    _buildFeatureItem(Icons.cloud_sync, '자동 저장 및 동기화',
                        '모든 변경 사항은 자동으로 저장되고 모든 기기에서 동기화됩니다.'),
                    const SizedBox(height: 24),
                    _buildFeatureItem(Icons.share, '간편한 공유',
                        '이력서를 쉽게 공유하고 PDF로 다운로드할 수 있습니다.'),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 오른쪽 영역 (로그인 폼)
        Expanded(
          child: Center(
            child: SizedBox(
              width: 450,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '계정에 로그인하여 이력서를 관리하세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLoginForm(context, isDesktop: true),
                    const SizedBox(height: 24),
                    // 소셜 로그인 버튼
                    const Center(
                      child: Text(
                        '또는 소셜 계정으로 로그인',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialLoginButton(
                          'Google',
                          Colors.red.shade400,
                          Icons.g_mobiledata,
                        ),
                        const SizedBox(width: 16),
                        _buildSocialLoginButton(
                          'Facebook',
                          Colors.blue.shade700,
                          Icons.facebook,
                        ),
                        const SizedBox(width: 16),
                        _buildSocialLoginButton(
                          'GitHub',
                          Colors.grey.shade800,
                          Icons.code,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 로그인 폼
  Widget _buildLoginForm(BuildContext context, {bool isDesktop = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 이메일 입력 필드
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return '유효한 이메일을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // 비밀번호 입력 필드
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              if (value.length < 6) {
                return '비밀번호는 최소 6자 이상이어야 합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // 로그인 옵션 (자동 로그인)
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const Text('자동 로그인'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: 비밀번호 찾기 기능 구현
                },
                child: const Text('비밀번호 찾기'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 로그인 버튼
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '로그인',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),
          // 회원가입 링크
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('계정이 없으신가요?'),
              TextButton(
                onPressed: () {
                  // TODO: 회원가입 화면으로 이동
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 데스크톱 화면의 특징 아이템
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white24,
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 소셜 로그인 버튼
  Widget _buildSocialLoginButton(String platform, Color color, IconData icon) {
    return InkWell(
      onTap: () {
        // TODO: 소셜 로그인 구현
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$platform 로그인은 아직 준비중입니다')),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
