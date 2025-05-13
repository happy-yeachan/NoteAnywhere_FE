import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resume_model.dart';
import '../utils/responsive_utils.dart';

class SharedResumesScreen extends StatefulWidget {
  const SharedResumesScreen({super.key});

  @override
  State<SharedResumesScreen> createState() => _SharedResumesScreenState();
}

class _SharedResumesScreenState extends State<SharedResumesScreen> {
  bool _isLoading = true;
  List<Resume> _sharedResumes = [];

  @override
  void initState() {
    super.initState();
    _loadSharedResumes();
  }

  Future<void> _loadSharedResumes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 API 연동 시 여기서 공유된 이력서 데이터 로드
      await Future.delayed(const Duration(seconds: 1));

      // 임시 데이터
      final now = DateTime.now();
      List<Resume> sharedResumes = List.generate(
        8,
        (index) => Resume(
          id: 'shared-$index',
          title: '공유된 이력서 ${index + 1}',
          content: '이력서 ${index + 1}의 내용입니다.',
          createdAt: now.subtract(Duration(days: index * 3)),
          updatedAt: now.subtract(Duration(days: index)),
          isShared: true,
          ownerName: '사용자 ${index + 1}',
          sharingUrl: 'https://resume-share.example.com/shared-$index',
        ),
      );

      setState(() {
        _sharedResumes = sharedResumes;
      });
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유된 이력서를 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공유된 이력서'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sharedResumes.isEmpty
              ? _buildEmptyState()
              : ResponsiveLayout(
                  mobile: _buildMobileSharedList(context),
                  desktop: _buildDesktopSharedList(context),
                ),
    );
  }

  // 모바일용 공유 이력서 목록
  Widget _buildMobileSharedList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadSharedResumes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sharedResumes.length,
        itemBuilder: (context, index) {
          final resume = _sharedResumes[index];
          return _buildResumeCard(resume);
        },
      ),
    );
  }

  // 데스크톱용 공유 이력서 목록
  Widget _buildDesktopSharedList(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveUtils.getContentMaxWidth(context),
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 타이틀
              const Text(
                '공유된 이력서 목록',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 필터 및 검색 영역
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '이력서 제목 또는 작성자 검색',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _loadSharedResumes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('새로고침'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 그리드 레이아웃의 공유 이력서 목록
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: _sharedResumes.length,
                  itemBuilder: (context, index) {
                    final resume = _sharedResumes[index];
                    return _buildDesktopResumeCard(resume);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 모바일용 이력서 카드
  Widget _buildResumeCard(Resume resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/viewer/${resume.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      resume.ownerName.isNotEmpty
                          ? resume.ownerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.ownerName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '공유일: ${_formatDate(resume.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                resume.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                resume.content.length > 100
                    ? '${resume.content.substring(0, 100)}...'
                    : resume.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('보기'),
                    onPressed: () => context.push('/viewer/${resume.id}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 데스크톱용 이력서 카드
  Widget _buildDesktopResumeCard(Resume resume) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/viewer/${resume.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 헤더 (작성자 정보)
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      resume.ownerName.isNotEmpty
                          ? resume.ownerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume.ownerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '공유일: ${_formatDate(resume.updatedAt)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              // 이력서 제목
              Text(
                resume.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // 이력서 내용 미리보기
              Expanded(
                child: Text(
                  resume.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 하단 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 공유 URL 복사 기능
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('공유 URL이 클립보드에 복사되었습니다.')),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('링크 복사'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/viewer/${resume.id}'),
                    icon: const Icon(Icons.visibility),
                    label: const Text('상세 보기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 공유된 이력서가 없을 때 표시할 위젯
  Widget _buildEmptyState() {
    return ResponsiveLayout(
      // 모바일용 빈 화면
      mobile: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '공유된 이력서가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 사용자가 이력서를 공유하면 여기에 표시됩니다',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSharedResumes,
              child: const Text('새로고침'),
            ),
          ],
        ),
      ),
      // 데스크톱용 빈 화면
      desktop: Center(
        child: SizedBox(
          width: 600,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: 96,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '공유된 이력서가 없습니다',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '다른 사용자가 이력서를 공유하면 여기에 표시됩니다.\n다른 사용자의 이력서를 받으면 즉시 여기에서 확인할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loadSharedResumes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('새로고침'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.home),
                        label: const Text('홈으로 돌아가기'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
