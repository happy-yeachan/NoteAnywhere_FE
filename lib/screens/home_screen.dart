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
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: 24),
          _buildMenuGrid(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveUtils.getContentMaxWidth(context),
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 40),
              _buildMenuGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이력서 어디서나에 오신 것을 환영합니다!',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '이력서를 작성하고 공유하며, 다른 사람들의 이력서를 검토해보세요.',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/editor'),
                  icon: const Icon(Icons.add),
                  label: const Text('새 이력서 작성'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: isDesktop ? 16 : 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/viewer/my-resumes'),
                  icon: const Icon(Icons.description),
                  label: const Text('내 이력서 목록'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: isDesktop ? 16 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return GridView.count(
      crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
      childAspectRatio: isDesktop ? 1.2 : 1.4,
      shrinkWrap: true,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuCard(
          context,
          title: '이력서 작성하기',
          icon: Icons.edit_document,
          description: '새로운 이력서를 작성하고 저장하세요.',
          onTap: () => context.push('/editor'),
          color: Colors.blueAccent,
        ),
        _buildMenuCard(
          context,
          title: '내 이력서 관리',
          icon: Icons.folder_outlined,
          description: '저장된 이력서를 관리하고 수정하세요.',
          onTap: () => context.push('/viewer/my-resumes'),
          color: Colors.greenAccent,
        ),
        _buildMenuCard(
          context,
          title: '공유된 이력서',
          icon: Icons.visibility,
          description: '다른 사용자가 공유한 이력서를 확인하세요.',
          onTap: () => context.push('/shared'),
          color: Colors.purpleAccent,
        ),
        _buildMenuCard(
          context,
          title: '검토 요청 관리',
          icon: Icons.rate_review,
          description: '받은 검토 요청과 보낸 검토 요청을 관리하세요.',
          onTap: () => context.push('/reviews'),
          color: Colors.orangeAccent,
        ),
        _buildMenuCard(
          context,
          title: '통계 및 분석',
          icon: Icons.bar_chart,
          description: '이력서 조회수와 피드백 통계를 확인하세요.',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('준비 중인 기능입니다.')),
            );
          },
          color: Colors.teal,
        ),
        _buildMenuCard(
          context,
          title: '도움말',
          icon: Icons.help_outline,
          description: '이력서 작성 도움말과 유용한 팁을 확인하세요.',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('준비 중인 기능입니다.')),
            );
          },
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
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
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
