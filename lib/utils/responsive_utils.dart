import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  // 디바이스에 따른 컨텐츠 최대 너비
  static double getContentMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width;
    } else if (isTablet(context)) {
      return 700;
    } else {
      return 1000;
    }
  }

  // 디바이스에 따른 패딩 설정
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
}

// 반응형 레이아웃을 위한 래퍼 위젯
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveUtils.isDesktop(context)) {
          return desktop ?? tablet ?? mobile;
        } else if (ResponsiveUtils.isTablet(context)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
