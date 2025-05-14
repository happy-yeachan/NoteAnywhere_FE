import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resume_model.dart';
import '../models/review_request_model.dart';
import '../utils/responsive_utils.dart';

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
  final String _userId = 'user-123'; // 임시 사용자 ID
  final String _userName = '사용자'; // 임시 사용자 이름
  bool _hasReachedViewLimit = false; // 무료 조회 한도 도달 여부

  @override
  void initState() {
    super.initState();
    _loadResume();
    _checkViewLimit();
  }

  // 무료 조회 한도 확인 (3개까지 무료 조회 가능)
  Future<void> _checkViewLimit() async {
    // 실제 구현 시에는 SharedPreferences나 API를 통해 확인
    setState(() {
      _hasReachedViewLimit = false; // 임시로 false 설정
    });
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
      final resume = Resume(
        id: widget.resumeId,
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
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ownerName: '홍길동',
        isShared: true,
        sharingUrl: 'https://resume.example.com/share/${widget.resumeId}',
        category: '개발',
        reviewPrice: 10000, // 기본 검토 가격 10,000원
      );

      setState(() {
        _resume = resume;
        _isShared = resume.isShared;
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

  // 검토 요청 다이얼로그 표시
  Future<void> _showReviewRequestDialog() async {
    if (_resume == null) return;

    // 조회 한도 확인
    if (_hasReachedViewLimit) {
      _showViewLimitDialog();
      return;
    }

    final TextEditingController messageController = TextEditingController();
    final TextEditingController priceController = TextEditingController(
      text: _resume!.reviewPrice.toStringAsFixed(0),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이력서 검토 요청'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${_resume!.ownerName}님에게 "${_resume!.title}" 이력서의 검토를 요청합니다.'),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: '제안 가격 (원)',
                    hintText: '제안할 검토 가격을 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: '요청 메시지',
                    hintText: '작성자에게 전할 메시지를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                // 검토 요청 생성 및 서버 전송 (현재는 임시 구현)
                final suggestedPrice = double.tryParse(priceController.text) ??
                    _resume!.reviewPrice;
                final message = messageController.text;

                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('요청 메시지를 입력해주세요')),
                  );
                  return;
                }

                // 검토 요청 객체 생성
                final reviewRequest = ReviewRequest.create(
                  requesterId: _userId,
                  requesterName: _userName,
                  reviewerId:
                      'owner-${_resume!.id}', // 실제로는 API에서 이력서 소유자 ID를 사용
                  reviewerName: _resume!.ownerName,
                  resumeId: _resume!.id,
                  resumeTitle: _resume!.title,
                  suggestedPrice: suggestedPrice,
                  message: message,
                );

                // 임시로 성공 메시지 표시
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이력서 검토 요청이 성공적으로 전송되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('요청 보내기'),
            ),
          ],
        );
      },
    );
  }

  // 무료 조회 한도 도달 다이얼로그
  void _showViewLimitDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('무료 조회 한도 도달'),
          content: const Text(
            '무료로 볼 수 있는 이력서 3개의 한도에 도달했습니다. '
            '더 많은 이력서를 보려면 자신의 이력서를 공유해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/'); // 홈으로 이동
              },
              child: const Text('내 이력서 공유하기'),
            ),
          ],
        );
      },
    );
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
                  : () {
                      if (_resume != null) {
                        context
                            .push('/editor', extra: {'resumeId': _resume!.id});
                      }
                    },
              tooltip: '이력서 수정하기',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resume == null
              ? const Center(child: Text('이력서를 찾을 수 없습니다'))
              : ResponsiveLayout(
                  mobile: _buildMobileResumeView(context),
                  desktop: _buildDesktopResumeView(context),
                ),
    );
  }

  // 모바일용 이력서 상세 뷰
  Widget _buildMobileResumeView(BuildContext context) {
    return SingleChildScrollView(
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

            // 작성자 정보 및 액션 버튼
            const Divider(height: 32),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    _resume!.ownerName.isNotEmpty
                        ? _resume!.ownerName[0].toUpperCase()
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
                      _resume!.ownerName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    if (_resume != null) {
                      context.push('/editor', extra: {'resumeId': _resume!.id});
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('수정하기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),
            // 이력서 내용
            Text(
              _resume!.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            // 좋아요 버튼
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_resume!.likedUserIds.contains(_userId)) {
                        _resume = _resume!.removeLike(_userId);
                      } else {
                        _resume = _resume!.addLike(_userId);
                      }
                    });
                    // 실제로는 API 호출하여 좋아요 상태 업데이트
                  },
                  icon: Icon(
                    _resume!.likedUserIds.contains(_userId)
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                  ),
                  label: Text('따봉 ${_resume!.likeCount}'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_resume != null) {
                      context.push('/editor', extra: {'resumeId': _resume!.id});
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('수정하기'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 데스크톱용 이력서 상세 뷰
  Widget _buildDesktopResumeView(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveUtils.getContentMaxWidth(context),
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 헤더 (제목 및 작성자 정보)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _resume!.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  radius: 16,
                                  child: Text(
                                    _resume!.ownerName.isNotEmpty
                                        ? _resume!.ownerName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _resume!.ownerName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '마지막 수정: ${_formatDate(_resume!.updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      // 액션 버튼 그룹
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 좋아요 버튼
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_resume!.likedUserIds.contains(_userId)) {
                                  _resume = _resume!.removeLike(_userId);
                                } else {
                                  _resume = _resume!.addLike(_userId);
                                }
                              });
                              // 실제로는 API 호출하여 좋아요 상태 업데이트
                            },
                            icon: Icon(
                              _resume!.likedUserIds.contains(_userId)
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                            ),
                            label: Text('따봉 ${_resume!.likeCount}'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_resume != null) {
                                context.push('/editor',
                                    extra: {'resumeId': _resume!.id});
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('이력서 수정하기'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 48),

                  // 이력서 내용
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _resume!.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Divider(height: 48),

                  // 하단 액션 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // PDF 다운로드 기능 (임시)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF 다운로드를 시작합니다...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('PDF 다운로드'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.home),
                        label: const Text('홈으로'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
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
          : ResponsiveLayout(
              mobile: _buildMobileResumeList(),
              desktop: _buildDesktopResumeList(),
            ),
    );
  }

  // 모바일용 이력서 목록
  Widget _buildMobileResumeList() {
    return ListView.builder(
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
    );
  }

  // 데스크톱용 이력서 목록
  Widget _buildDesktopResumeList() {
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
                '내 이력서 목록',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // 새 이력서 생성 버튼
              ElevatedButton.icon(
                onPressed: () => context.push('/editor'),
                icon: const Icon(Icons.add),
                label: const Text('새 이력서 작성하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 그리드 형태의 이력서 목록
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 8, // 임시 데이터 수
                  itemBuilder: (context, index) {
                    // 임시 데이터
                    final resume = Resume.create(
                      title: '이력서 ${index + 1}',
                      content: '이력서 내용 ${index + 1}. 여기에는 더 많은 내용이 들어갈 수 있습니다.',
                    );

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => context.push('/viewer/${resume.id}'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resume.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '마지막 수정: ${_formatDate(resume.updatedAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Text(
                                  resume.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        context.push('/viewer/${resume.id}'),
                                    child: const Text('보기'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
