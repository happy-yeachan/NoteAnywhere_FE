import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이력서 어디서나'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  // 모바일용 레이아웃
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // 서비스 설명 카드
            _buildServiceInfoCard(context),
            const SizedBox(height: 30),
            // 메인 메뉴 버튼들
            _buildMenuButton(
              context: context,
              title: '새 이력서 작성하기',
              icon: Icons.create_outlined,
              onTap: () => context.push('/editor'),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context: context,
              title: '내 이력서 보기',
              icon: Icons.description_outlined,
              onTap: () => context.push('/viewer/my-resumes'),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context: context,
              title: '공유된 이력서 보기',
              icon: Icons.share_outlined,
              onTap: () => context.push('/shared'),
            ),
          ],
        ),
      ),
    );
  }

  // 데스크톱용 레이아웃
  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveUtils.getContentMaxWidth(context),
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 서비스 설명 카드 - 더 큰 버전
              _buildServiceInfoCard(context, isDesktop: true),
              const SizedBox(height: 50),
              // 메뉴 버튼들을 가로로 배치
              Row(
                children: [
                  Expanded(
                    child: _buildDesktopMenuCard(
                      context: context,
                      title: '새 이력서 작성하기',
                      icon: Icons.create_outlined,
                      description: '새로운 이력서를 작성하고 저장합니다.',
                      onTap: () => context.push('/editor'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildDesktopMenuCard(
                      context: context,
                      title: '내 이력서 보기',
                      icon: Icons.description_outlined,
                      description: '저장된 이력서 목록을 확인하고 관리합니다.',
                      onTap: () => context.push('/viewer/my-resumes'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildDesktopMenuCard(
                      context: context,
                      title: '공유된 이력서 보기',
                      icon: Icons.share_outlined,
                      description: '다른 사용자가 공유한 이력서를 확인합니다.',
                      onTap: () => context.push('/shared'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 서비스 설명 카드
  Widget _buildServiceInfoCard(BuildContext context, {bool isDesktop = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16.0 : 12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '어디서든 이력서를 관리하세요',
              style: isDesktop
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: isDesktop ? 16.0 : 10.0),
            Text(
              '이력서를 작성하고, 수정하고, 공유하는 모든 것을 한 곳에서 할 수 있습니다.',
              style: isDesktop
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyMedium,
            ),
            if (isDesktop) ...[
              const SizedBox(height: 24),
              const Text(
                '다양한 기기에서 이력서에 접근하고, 언제 어디서나 수정할 수 있으며, 필요할 때 다른 사람과 쉽게 공유할 수 있습니다. 이력서를 PDF로 변환하거나 다운로드할 수도 있습니다.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 모바일용 메뉴 버튼
  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 데스크톱용 메뉴 카드
  Widget _buildDesktopMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
