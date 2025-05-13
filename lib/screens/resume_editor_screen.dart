import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resume_model.dart';
import '../utils/responsive_utils.dart';

class ResumeEditorScreen extends StatefulWidget {
  final String? resumeId;

  const ResumeEditorScreen({
    super.key,
    this.resumeId,
  });

  @override
  State<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends State<ResumeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  Resume? _resume;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.resumeId != null;

    // 실제 앱에서는 여기서 이력서 데이터를 로드
    if (_isEditing) {
      _loadResume();
    }
  }

  Future<void> _loadResume() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 API를 통해 이력서 로드하기
      // 임시 데이터
      await Future.delayed(const Duration(milliseconds: 500));
      final resume = Resume.create(
        title: '테스트 이력서',
        content: '이력서 내용입니다.',
      );

      setState(() {
        _resume = resume;
        _titleController.text = resume.title;
        _contentController.text = resume.content;
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

  Future<void> _saveResume() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      // 편집 모드인 경우 이력서 업데이트
      if (_isEditing && _resume != null) {
        final updatedResume = _resume!.copyWith(
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        );

        // TODO: API 연동
        await Future.delayed(const Duration(seconds: 1));

        // 저장 성공 메시지
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이력서가 업데이트되었습니다')),
          );
          context.pop();
        }
      }
      // 새 이력서 작성
      else {
        final newResume = Resume.create(
          title: title,
          content: content,
        );

        // TODO: API 연동
        await Future.delayed(const Duration(seconds: 1));

        // 저장 성공 메시지
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새 이력서가 저장되었습니다')),
          );
          context.pop();
        }
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이력서 저장에 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '이력서 수정하기' : '새 이력서 작성하기'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveResume,
            child: const Text('저장'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(context),
              desktop: _buildDesktopLayout(context),
            ),
    );
  }

  // 모바일 레이아웃
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildForm(context),
      ),
    );
  }

  // 데스크톱 레이아웃
  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveUtils.getContentMaxWidth(context),
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildForm(context, isDesktop: true),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 폼 빌더
  Widget _buildForm(BuildContext context, {bool isDesktop = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) ...[
            Text(
              _isEditing ? '이력서 수정하기' : '새 이력서 작성하기',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
          // 제목 입력 필드
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '제목',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 12.0 : 8.0),
              ),
              contentPadding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
            ),
            style: isDesktop
                ? const TextStyle(fontSize: 18)
                : const TextStyle(fontSize: 16),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '제목을 입력해주세요';
              }
              return null;
            },
          ),
          SizedBox(height: isDesktop ? 24.0 : 16.0),
          // 내용 입력 필드
          TextFormField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: '내용',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 12.0 : 8.0),
              ),
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
            ),
            maxLines: isDesktop ? 25 : 20,
            style: isDesktop
                ? const TextStyle(fontSize: 16)
                : const TextStyle(fontSize: 14),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '내용을 입력해주세요';
              }
              return null;
            },
          ),
          SizedBox(height: isDesktop ? 32.0 : 24.0),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveResume,
                  icon: const Icon(Icons.save),
                  label: const Text('저장하기'),
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
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('취소'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _isLoading ? null : _saveResume,
              child: const Text('저장하기'),
            ),
        ],
      ),
    );
  }
}
