import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resume_model.dart';

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
              : RefreshIndicator(
                  onRefresh: _loadSharedResumes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sharedResumes.length,
                    itemBuilder: (context, index) {
                      final resume = _sharedResumes[index];
                      return _buildResumeCard(resume);
                    },
                  ),
                ),
    );
  }

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

  Widget _buildEmptyState() {
    return Center(
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
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSharedResumes,
            child: const Text('새로고침'),
          ),
        ],
      ),
    );
  }

  // 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
