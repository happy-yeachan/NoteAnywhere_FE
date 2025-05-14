import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math' as math;
import 'package:flutter/gestures.dart'; // PointerScrollEvent를 위한 import 추가
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
  String? _resumeId;
  bool _initialized = false;
  bool _isShared = false;
  bool _isPreviewMode = false;
  bool _isAutoSaving = false;
  Timer? _autoSaveTimer;
  final _sectionControllers = {
    'introduction': TextEditingController(),
    'education': TextEditingController(),
    'experience': TextEditingController(),
    'skills': TextEditingController(),
    'projects': TextEditingController(),
    'certifications': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _resumeId = widget.resumeId;
    _startAutoSave();
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isAutoSaving) return;
      
      final currentContent = _contentController.text;
      if (currentContent.isNotEmpty) {
        setState(() {
          _isAutoSaving = true;
        });
        
        // TODO: 실제 API를 통해 자동 저장
        Future.delayed(const Duration(seconds: 1)).then((_) {
          if (mounted) {
            setState(() {
              _isAutoSaving = false;
            });
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // GoRouter에서 extra 매개변수를 통해 전달된 resumeId가 있는지 확인
      final extra = GoRouterState.of(context).extra;
      if (extra != null &&
          extra is Map<String, dynamic> &&
          extra.containsKey('resumeId')) {
        _resumeId = extra['resumeId'] as String?;
      }

      _isEditing = _resumeId != null;

      // 실제 앱에서는 여기서 이력서 데이터를 로드
      if (_isEditing) {
        _loadResume();
      } else {
        // 새 이력서 작성 시 기본 템플릿 제공
        _contentController.text = '''# 자기소개
안녕하세요, 저는 [이름]입니다.

## 학력
- [학교명], [전공], [기간]

## 경력
- [회사명], [직위], [기간]
  - [주요 업무 및 성과]

## 기술 스택
- 언어: 
- 프레임워크: 
- 도구: 

## 프로젝트 경험
### [프로젝트명]
- 기간: [기간]
- 설명: [프로젝트 설명]
- 역할: [담당 역할]
- 성과: [주요 성과]

## 자격증 및 수상 내역
- [자격증/수상명], [발급/수상 기관], [날짜]
''';
      }

      _initialized = true;
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
        title: '테스트 이력서 ($_resumeId)',
        content: '''# 자기소개
안녕하세요, 저는 홍길동입니다.

## 학력
- 서울대학교, 컴퓨터공학과, 2016-2020

## 경력
- ABC 회사, 소프트웨어 엔지니어, 2020-현재
  - 주요 프로젝트 개발 및 유지보수
  - 신기술 도입 및 적용

## 기술 스택
- 언어: Python, JavaScript, Java
- 프레임워크: Django, React, Spring Boot
- 도구: Git, Docker, AWS

## 프로젝트 경험
### 이력서 관리 시스템
- 기간: 2023.01 - 2023.06
- 설명: 사용자가 온라인으로 이력서를 작성하고 관리할 수 있는 웹 애플리케이션
- 역할: 풀스택 개발
- 성과: 사용자 만족도 90% 달성

## 자격증 및 수상 내역
- 정보처리기사, 한국산업인력공단, 2019.05
''',
      );

      setState(() {
        _resume = resume;
        _titleController.text = resume.title;
        _contentController.text = resume.content;
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
          isShared: _isShared,
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
          isShared: _isShared,
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
    _autoSaveTimer?.cancel();
    _sectionControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildSectionEditor(BuildContext context, String title, String hint, TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: (value) {
                _updateContent();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateContent() {
    final content = [
      '# 자기소개\n${_sectionControllers['introduction']!.text}\n\n',
      '## 학력\n${_sectionControllers['education']!.text}\n\n',
      '## 경력\n${_sectionControllers['experience']!.text}\n\n',
      '## 기술 스택\n${_sectionControllers['skills']!.text}\n\n',
      '## 프로젝트 경험\n${_sectionControllers['projects']!.text}\n\n',
      '## 자격증 및 수상 내역\n${_sectionControllers['certifications']!.text}',
    ].join();
    
    _contentController.text = content;
  }

  Widget _buildSectionEditor(BuildContext context, String title, String hint, TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: (value) {
                _updateContent();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateContent() {
    final content = [
      '# 자기소개\n${_sectionControllers['introduction']!.text}\n\n',
      '## 학력\n${_sectionControllers['education']!.text}\n\n',
      '## 경력\n${_sectionControllers['experience']!.text}\n\n',
      '## 기술 스택\n${_sectionControllers['skills']!.text}\n\n',
      '## 프로젝트 경험\n${_sectionControllers['projects']!.text}\n\n',
      '## 자격증 및 수상 내역\n${_sectionControllers['certifications']!.text}',
    ].join();
    
    _contentController.text = content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '이력서 수정하기' : '새 이력서 작성하기'),
        elevation: 0,
        actions: [
          // 미리보기 모드 토글 버튼
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
            tooltip: _isPreviewMode ? '편집 모드로 전환' : '미리보기 모드로 전환',
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
          ),
          TextButton(
            onPressed: _isLoading ? null : _saveResume,
            child: const Text('저장'),
          ),
        ],
      ),
      body: GestureDetector(
        // 빈 공간 터치 시 키보드 닫기
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ResponsiveLayout(
                mobile: _buildMobileLayout(context),
                desktop: _buildDesktopLayout(context),
              ),
      ),
    );
  }

  // 모바일 레이아웃
  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            physics: const AlwaysScrollableScrollPhysics(),
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Form(
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

            // 이력서 섹션별 편집
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 섹션별 편집
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(isDesktop ? 12.0 : 8.0),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 자기소개
                          _buildSectionEditor(
                            context,
                            '자기소개',
                            '간단한 자기소개를 작성해주세요.',
                            _sectionControllers['introduction']!,
                          ),
                          const SizedBox(height: 16),
                          
                          // 학력
                          _buildSectionEditor(
                            context,
                            '학력',
                            '학교명, 전공, 기간을 작성해주세요.',
                            _sectionControllers['education']!,
                          ),
                          const SizedBox(height: 16),
                          
                          // 경력
                          _buildSectionEditor(
                            context,
                            '경력',
                            '회사명, 직위, 기간, 주요 업무를 작성해주세요.',
                            _sectionControllers['experience']!,
                          ),
                          const SizedBox(height: 16),
                          
                          // 기술 스택
                          _buildSectionEditor(
                            context,
                            '기술 스택',
                            '사용 가능한 기술들을 나열해주세요.',
                            _sectionControllers['skills']!,
                          ),
                          const SizedBox(height: 16),
                          
                          // 프로젝트 경험
                          _buildSectionEditor(
                            context,
                            '프로젝트 경험',
                            '프로젝트명, 기간, 역할, 성과를 작성해주세요.',
                            _sectionControllers['projects']!,
                          ),
                          const SizedBox(height: 16),
                          
                          // 자격증 및 수상 내역
                          _buildSectionEditor(
                            context,
                            '자격증 및 수상 내역',
                            '자격증명, 발급기관, 수상명, 수상일을 작성해주세요.',
                            _sectionControllers['certifications']!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 오른쪽: 실시간 미리보기
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(isDesktop ? 12.0 : 8.0),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Markdown(
                        data: _contentController.text,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          h2: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          h3: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          p: TextStyle(
                              fontSize: isDesktop ? 16 : 14, height: 1.5),
                        ),
                        shrinkWrap: true,
                        selectable: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 24.0 : 16.0),

            // 미리보기 전환 버튼
            Row(
              children: [
                Expanded(
                  child: Text(
                    '내용',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
                  label: Text(_isPreviewMode ? '편집 모드' : '미리보기 모드'),
                  onPressed: () {
                    setState(() {
                      _isPreviewMode = !_isPreviewMode;
                    });
                  },
                  return true;
                },
                child: Column(
                  children: [
                    // 마크다운 도구 모음
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isDesktop ? 12.0 : 8.0),
                          topRight: Radius.circular(isDesktop ? 12.0 : 8.0),
                            topLeft: Radius.circular(isDesktop ? 12.0 : 8.0),
                            topRight: Radius.circular(isDesktop ? 12.0 : 8.0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics:
                              const ClampingScrollPhysics(), // 수평 스크롤 물리 효과 추가
                          child: Wrap(
                            spacing: 2,
                            children: [
                              _buildMarkdownButton(
                                icon: Icons.title,
                                tooltip: '제목 1',
                                onPressed: () => _insertMarkdown('# ', ' '),
                              ),
                              _buildMarkdownButton(
                                icon: Icons.title,
                                tooltip: '제목 2',
                                onPressed: () => _insertMarkdown('## ', ' '),
                                scale: 0.9,
                              ),
                              _buildMarkdownButton(
                                icon: Icons.title,
                                tooltip: '제목 3',
                                onPressed: () => _insertMarkdown('### ', ' '),
                                scale: 0.8,
                              ),
                              const SizedBox(width: 4),
                              _buildMarkdownButton(
                                icon: Icons.format_bold,
                                tooltip: '굵게',
                                onPressed: () => _insertMarkdown('**', '**'),
                              ),
                              _buildMarkdownButton(
                                icon: Icons.format_italic,
                                tooltip: '기울임',
                                onPressed: () => _insertMarkdown('*', '*'),
                              ),
                              _buildMarkdownButton(
                                icon: Icons.format_strikethrough,
                                tooltip: '취소선',
                                onPressed: () => _insertMarkdown('~~', '~~'),
                              ),
                              const SizedBox(width: 4),
                              _buildMarkdownButton(
                                icon: Icons.format_list_bulleted,
                                tooltip: '글머리 기호',
                                onPressed: () => _insertMarkdown('- ', '\n'),
                              ),
                              _buildMarkdownButton(
                                icon: Icons.format_list_numbered,
                                tooltip: '번호 목록',
                                onPressed: () => _insertMarkdown('1. ', '\n'),
                              ),
                              const SizedBox(width: 4),
                              _buildMarkdownButton(
                                icon: Icons.table_chart,
                                tooltip: '표',
                                onPressed: () => _insertMarkdown('''
| 제목1 | 제목2 | 제목3 |
|------|------|------|
| 내용1 | 내용2 | 내용3 |
''', '\n'),
                              ),
                              _buildMarkdownButton(
                                icon: Icons.code,
                                tooltip: '코드',
                                onPressed: () =>
                                    _insertMarkdown('```\n', '\n```'),
                              ),
                              _buildMarkdownButton(
                                icon: Icons.link,
                                tooltip: '링크',
                                onPressed: () =>
                                    _insertMarkdown('[링크 텍스트](', ')'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 에디터 영역
                      Expanded(
                        child: GestureDetector(
                          // 여백 영역도 터치 가능하게 함
                          behavior: HitTestBehavior.translucent,
                          // 더블 탭으로 에디터에 포커스 주기
                          onDoubleTap: () =>
                              FocusScope.of(context).requestFocus(
                            FocusNode(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                              controller: _contentController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '마크다운으로 이력서 내용을 작성해보세요...',
                                isCollapsed: true, // 내부 패딩 제거
                              ),
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                height: 1.5,
                                fontFamily: 'Roboto Mono', // 모노스페이스 폰트 사용
                              ),
                              maxLines: null,
                              expands: true, // 사용 가능한 공간을 모두 채우도록 함
                              textAlignVertical:
                                  TextAlignVertical.top, // 텍스트를 상단에서부터 시작
                              keyboardType:
                                  TextInputType.multiline, // 멀티라인 입력 활성화
                              textInputAction:
                                  TextInputAction.newline, // 엔터키로 줄바꿈
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '내용을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: isDesktop ? 24.0 : 16.0),

            // 공개 여부 선택 스위치
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 12.0 : 8.0),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '이력서 공개 설정',
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '공개로 설정하면 다른 사용자가 내 이력서를 볼 수 있습니다.',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isShared,
                      onChanged: (value) {
                        setState(() {
                          _isShared = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }

  // 마크다운 버튼 위젯
  Widget _buildMarkdownButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    double scale = 1.0,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20 * scale,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // 마크다운 텍스트 삽입 헬퍼 메서드
  void _insertMarkdown(String prefix, String suffix) {
    // 현재 커서 위치 또는 선택된 텍스트 범위
    final currentText = _contentController.text;
    final selection = _contentController.selection;

    // 텍스트 필드에 포커스가 없는 경우 (선택 범위가 유효하지 않음)
    if (selection.baseOffset < 0) {
      // 텍스트의 끝에 마크다운 삽입
      _contentController.text = '$currentText$prefix$suffix';

      // 마크다운 사이에 커서 위치시키기
      _contentController.selection = TextSelection.collapsed(
        offset: _contentController.text.length - suffix.length,
      );
      return;
    }

    // 안전한 범위 계산
    final baseOffset =
        math.min(math.max(0, selection.baseOffset), currentText.length);
    final extentOffset =
        math.min(math.max(0, selection.extentOffset), currentText.length);

    // 삽입 전 텍스트
    final beforeSelection = currentText.substring(0, baseOffset);

    // 선택된 텍스트 또는 빈 문자열
    final selectedText = baseOffset == extentOffset
        ? ''
        : currentText.substring(baseOffset, extentOffset);

    // 삽입 후 텍스트
    final afterSelection = currentText.substring(extentOffset);

    // 새로운 텍스트 구성
    final newText =
        '$beforeSelection$prefix$selectedText$suffix$afterSelection';

    // 새로운 선택 범위 계산
    final newSelectionOffset = baseOffset + prefix.length;

    // 새로운 텍스트로 TextEditingController 업데이트
    _contentController.value = TextEditingValue(
      text: newText,
      selection: selectedText.isEmpty
          ? TextSelection.collapsed(offset: newSelectionOffset)
          : TextSelection(
              baseOffset: newSelectionOffset,
              extentOffset: newSelectionOffset + selectedText.length,
            ),
    );
  }
}
