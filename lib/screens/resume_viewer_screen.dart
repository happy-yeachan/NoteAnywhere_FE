import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resume_model.dart';

class ResumeViewerScreen extends StatefulWidget {
  final String resumeId;

  const ResumeViewerScreen({
    super.key,
    required this.resumeId,
  });

  @override
  State<ResumeViewerScreen> createState() => _ResumeViewerScreenState();
}

class _ResumeViewerScreenState extends State<ResumeViewerScreen> {
  bool _isLoading = true;
  Resume? _resume;
  bool _isShared = false;

  @override
  void initState() {
    super.initState();
    _loadResume();
  }

  Future<void> _loadResume() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // widget.resumeId가 'my-resumes'인 경우 내 이력서 목록을 보여주기 위한 처리
      if (widget.resumeId == 'my-resumes') {
        // 실제 구현에서는 API로 내 이력서 목록을 로딩
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 실제 API 연동 시 여기서 이력서 데이터 로드
      await Future.delayed(const Duration(milliseconds: 800));

      // 임시 데이터
      final resume = Resume.create(
        title: '테스트 이력서',
        content: '''안녕하세요, 이력서 서비스입니다.

이 곳에서 이력서 내용을 확인할 수 있습니다.
다양한 정보를 포함할 수 있으며, 언제든지 내용을 수정하거나 공유할 수 있습니다.

이력서 내용은 다음과 같은 정보를 포함할 수 있습니다:
- 개인 정보
- 학력 사항
- 경력 사항
- 자격증
- 수상 내역
- 프로젝트 경험
- 기술 스택
''',
      );

      setState(() {
        _resume = resume;
        _isShared = false; // 공유 상태 설정, 실제로는 API 응답에서 받아옴
      });
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이력서를 불러오는데 실패했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleShare() async {
    if (_resume == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 공유 상태 토글 API 호출 (실제로는 API로 처리)
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isShared = !_isShared;
      });

      // 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isShared ? '이력서가 공유되었습니다' : '이력서 공유가 해제되었습니다'),
          ),
        );
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이력서 공유 상태 변경에 실패했습니다: $e')),
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
    // 'my-resumes' ID인 경우 이력서 목록 화면 표시
    if (widget.resumeId == 'my-resumes') {
      return _buildResumeList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_resume?.title ?? '이력서 상세'),
        elevation: 0,
        actions: [
          if (_resume != null) ...[
            IconButton(
              icon: Icon(_isShared ? Icons.share : Icons.share_outlined),
              onPressed: _isLoading ? null : _toggleShare,
              tooltip: _isShared ? '공유 해제' : '공유하기',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isLoading
                  ? null
                  : () =>
                      context.push('/editor', extra: {'resumeId': _resume!.id}),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resume == null
              ? const Center(child: Text('이력서를 찾을 수 없습니다'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이력서 제목
                        Text(
                          _resume!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        // 마지막 수정 날짜
                        Text(
                          '마지막 수정: ${_formatDate(_resume!.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Divider(height: 32),
                        // 이력서 내용
                        Text(
                          _resume!.content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // 이력서 목록 화면
  Widget _buildResumeList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 이력서'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/editor'),
        icon: const Icon(Icons.add),
        label: const Text('새 이력서'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // 임시 데이터 수
              itemBuilder: (context, index) {
                // 임시 데이터
                final resume = Resume.create(
                  title: '이력서 ${index + 1}',
                  content: '내용 ${index + 1}',
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(resume.title),
                    subtitle: Text(
                      '마지막 수정: ${_formatDate(resume.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/viewer/${resume.id}'),
                  ),
                );
              },
            ),
    );
  }

  // 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
