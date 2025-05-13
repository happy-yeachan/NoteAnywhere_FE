import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/review_request_model.dart';
import '../utils/responsive_utils.dart';

class ReviewRequestsScreen extends StatefulWidget {
  const ReviewRequestsScreen({super.key});

  @override
  State<ReviewRequestsScreen> createState() => _ReviewRequestsScreenState();
}

class _ReviewRequestsScreenState extends State<ReviewRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ReviewRequest> _receivedRequests = [];
  List<ReviewRequest> _sentRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviewRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 API 연동 시 여기서 검토 요청 데이터 로드
      await Future.delayed(const Duration(seconds: 1));

      // 임시 데이터
      final now = DateTime.now();
      const userId = 'user-123'; // 임시 사용자 ID

      // 받은 검토 요청
      List<ReviewRequest> receivedRequests = List.generate(
        5,
        (index) => ReviewRequest(
          id: 'received-$index',
          requesterId: 'requester-$index',
          requesterName: '요청자 ${index + 1}',
          reviewerId: userId,
          reviewerName: '내 이름',
          resumeId: 'resume-$index',
          resumeTitle: '검토 요청된 이력서 ${index + 1}',
          suggestedPrice: (index + 1) * 10000.0,
          message:
              '이력서 검토 부탁드립니다. 특히 ${_getRandomFocus()} 부분에 중점을 두고 봐주시면 감사하겠습니다.',
          createdAt: now.subtract(Duration(days: index)),
          status: _getRandomStatus(index),
        ),
      );

      // 보낸 검토 요청
      List<ReviewRequest> sentRequests = List.generate(
        3,
        (index) => ReviewRequest(
          id: 'sent-$index',
          requesterId: userId,
          requesterName: '내 이름',
          reviewerId: 'reviewer-$index',
          reviewerName: '검토자 ${index + 1}',
          resumeId: 'my-resume-$index',
          resumeTitle: '내 이력서 ${index + 1}',
          suggestedPrice: (index + 1) * 8000.0,
          message:
              '이력서 검토 부탁드립니다. ${_getRandomFocus()} 부분에 중점을 두고 봐주시면 감사하겠습니다.',
          createdAt: now.subtract(Duration(days: index + 1)),
          status: _getRandomStatus(index + 2),
        ),
      );

      setState(() {
        _receivedRequests = receivedRequests;
        _sentRequests = sentRequests;
      });
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검토 요청을 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 임시 데이터 생성을 위한 랜덤 검토 포커스
  String _getRandomFocus() {
    final focuses = ['경력', '학력', '자기소개', '프로젝트', '기술 스택', '자격증'];
    return focuses[DateTime.now().millisecondsSinceEpoch % focuses.length];
  }

  // 임시 데이터 생성을 위한 랜덤 상태
  ReviewRequestStatus _getRandomStatus(int index) {
    if (index % 4 == 0) return ReviewRequestStatus.pending;
    if (index % 4 == 1) return ReviewRequestStatus.accepted;
    if (index % 4 == 2) return ReviewRequestStatus.completed;
    return ReviewRequestStatus.rejected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검토 요청 관리'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '받은 요청'),
            Tab(text: '보낸 요청'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 받은 요청 탭
                _receivedRequests.isEmpty
                    ? _buildEmptyState('받은 검토 요청이 없습니다')
                    : ResponsiveLayout(
                        mobile:
                            _buildMobileRequestList(_receivedRequests, true),
                        desktop:
                            _buildDesktopRequestList(_receivedRequests, true),
                      ),
                // 보낸 요청 탭
                _sentRequests.isEmpty
                    ? _buildEmptyState('보낸 검토 요청이 없습니다')
                    : ResponsiveLayout(
                        mobile: _buildMobileRequestList(_sentRequests, false),
                        desktop: _buildDesktopRequestList(_sentRequests, false),
                      ),
              ],
            ),
    );
  }

  // 빈 화면 표시
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReviewRequests,
            child: const Text('새로고침'),
          ),
        ],
      ),
    );
  }

  // 모바일용 검토 요청 목록
  Widget _buildMobileRequestList(
      List<ReviewRequest> requests, bool isReceived) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상태 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(request.status),
                    Text(
                      '₩${request.suggestedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 요청 정보
                Text(
                  isReceived ? request.requesterName : request.reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '이력서: ${request.resumeTitle}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  '요청일: ${_formatDate(request.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                // 요청 메시지
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    request.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                // 응답이 있는 경우 표시
                if (request.reviewComment != null) ...[
                  Text(
                    '검토 코멘트:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.reviewComment!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // 액션 버튼
                if (isReceived && request.status == ReviewRequestStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showRejectDialog(request),
                        child: const Text('거절'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _acceptRequest(request),
                        child: const Text('수락'),
                      ),
                    ],
                  )
                else if (isReceived &&
                    request.status == ReviewRequestStatus.accepted)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showCompleteDialog(request),
                        child: const Text('검토 완료'),
                      ),
                    ],
                  )
                else if (!isReceived &&
                    request.status == ReviewRequestStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _cancelRequest(request),
                        child: const Text('요청 취소'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 데스크톱용 검토 요청 목록
  Widget _buildDesktopRequestList(
      List<ReviewRequest> requests, bool isReceived) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: ResponsiveUtils.getContentMaxWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                isReceived ? '받은 검토 요청' : '보낸 검토 요청',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상태 및 가격
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusChip(request.status),
                              Text(
                                '₩${request.suggestedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 요청 정보
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                                child: Text(
                                  isReceived
                                      ? request.requesterName[0].toUpperCase()
                                      : request.reviewerName[0].toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isReceived
                                        ? request.requesterName
                                        : request.reviewerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(request.createdAt),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '이력서: ${request.resumeTitle}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // 요청 메시지
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  request.message,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 액션 버튼
                          if (isReceived &&
                              request.status == ReviewRequestStatus.pending)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _showRejectDialog(request),
                                  child: const Text('거절'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _acceptRequest(request),
                                  child: const Text('수락'),
                                ),
                              ],
                            )
                          else if (isReceived &&
                              request.status == ReviewRequestStatus.accepted)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showCompleteDialog(request),
                                  child: const Text('검토 완료'),
                                ),
                              ],
                            )
                          else if (!isReceived &&
                              request.status == ReviewRequestStatus.pending)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _cancelRequest(request),
                                  child: const Text('요청 취소'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 상태 칩 생성
  Widget _buildStatusChip(ReviewRequestStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case ReviewRequestStatus.pending:
        chipColor = Colors.blue;
        statusText = '대기 중';
        break;
      case ReviewRequestStatus.accepted:
        chipColor = Colors.orange;
        statusText = '진행 중';
        break;
      case ReviewRequestStatus.completed:
        chipColor = Colors.green;
        statusText = '완료';
        break;
      case ReviewRequestStatus.rejected:
        chipColor = Colors.grey;
        statusText = '거절됨';
        break;
      case ReviewRequestStatus.cancelled:
        chipColor = Colors.red;
        statusText = '취소됨';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  // 검토 요청 수락
  Future<void> _acceptRequest(ReviewRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제로는 API 호출하여 상태 변경
      await Future.delayed(const Duration(milliseconds: 500));

      // 상태 업데이트
      final updatedRequest = request.accept();

      setState(() {
        final index = _receivedRequests.indexWhere((r) => r.id == request.id);
        if (index != -1) {
          _receivedRequests[index] = updatedRequest;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검토 요청을 수락했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검토 요청 수락에 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 검토 요청 거절 다이얼로그
  Future<void> _showRejectDialog(ReviewRequest request) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('검토 요청 거절'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('거절 이유를 입력해주세요:'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: '거절 이유',
                    hintText: '거절 이유를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                final reason = reasonController.text;
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('거절 이유를 입력해주세요')),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _rejectRequest(request, reason);
              },
              child: const Text('거절하기'),
            ),
          ],
        );
      },
    );
  }

  // 검토 요청 거절
  Future<void> _rejectRequest(ReviewRequest request, String reason) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제로는 API 호출하여 상태 변경
      await Future.delayed(const Duration(milliseconds: 500));

      // 상태 업데이트
      final updatedRequest = request.reject(reason);

      setState(() {
        final index = _receivedRequests.indexWhere((r) => r.id == request.id);
        if (index != -1) {
          _receivedRequests[index] = updatedRequest;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검토 요청을 거절했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검토 요청 거절에 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 검토 완료 다이얼로그
  Future<void> _showCompleteDialog(ReviewRequest request) async {
    final TextEditingController commentController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('검토 완료'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('검토 코멘트를 입력해주세요:'),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: '검토 코멘트',
                    hintText: '검토 코멘트를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
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
                final comment = commentController.text;
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('검토 코멘트를 입력해주세요')),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _completeRequest(request, comment);
              },
              child: const Text('완료하기'),
            ),
          ],
        );
      },
    );
  }

  // 검토 완료 처리
  Future<void> _completeRequest(ReviewRequest request, String comment) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제로는 API 호출하여 상태 변경
      await Future.delayed(const Duration(milliseconds: 500));

      // 상태 업데이트
      final updatedRequest = request.complete(comment);

      setState(() {
        final index = _receivedRequests.indexWhere((r) => r.id == request.id);
        if (index != -1) {
          _receivedRequests[index] = updatedRequest;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('검토를 완료했습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검토 완료 처리에 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 검토 요청 취소
  Future<void> _cancelRequest(ReviewRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제로는 API 호출하여 상태 변경
      await Future.delayed(const Duration(milliseconds: 500));

      // 상태 업데이트
      final updatedRequest = request.cancel();

      setState(() {
        final index = _sentRequests.indexWhere((r) => r.id == request.id);
        if (index != -1) {
          _sentRequests[index] = updatedRequest;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검토 요청을 취소했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검토 요청 취소에 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
