import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/resume_model.dart';

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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 제목 입력 필드
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // 내용 입력 필드
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: '내용',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 20,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '내용을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
