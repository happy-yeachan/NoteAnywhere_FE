import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/resume_editor_screen.dart';
import 'screens/resume_viewer_screen.dart';
import 'screens/shared_resumes_screen.dart';
import 'screens/login_screen.dart';
import 'screens/review_requests_screen.dart';

void main() {
  runApp(const MyApp());
}

// 라우터 설정
final _router = GoRouter(
  initialLocation: '/login', // 초기 경로를 로그인 화면으로 설정
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const ResumeEditorScreen(),
    ),
    GoRoute(
      path: '/viewer/:id',
      builder: (context, state) => ResumeViewerScreen(
        resumeId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/shared',
      builder: (context, state) => const SharedResumesScreen(),
    ),
    GoRoute(
      path: '/reviews',
      builder: (context, state) => const ReviewRequestsScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '이력서 어디서나',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // 눈이 편안한 UI를 위한 테마 설정
        brightness: Brightness.light,
        fontFamily: 'Pretendard',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // 다크 모드 테마
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      themeMode: ThemeMode.system, // 시스템 설정에 따라 테마 변경
      routerConfig: _router,
    );
  }
}
