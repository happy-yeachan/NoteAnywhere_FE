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
  List<Resume> _filteredResumes = [];

  // 검색 필터 관련 상태
  final _searchController = TextEditingController();
  String _selectedSortOption = '최신순';
  String _selectedCategory = '전체';
  bool _isSearchExpanded = false; // 데스크톱에서 검색창 확장 여부

  // 정렬 옵션 목록
  final List<String> _sortOptions = ['최신순', '오래된순', '제목순', '작성자순'];

  // 카테고리 목록
  final List<String> _categories = [
    '전체',
    '개발',
    '디자인',
    '마케팅',
    '기획',
    '영업',
    '인사',
    '기타'
  ];

  @override
  void initState() {
    super.initState();
    _loadSharedResumes();

    // 검색어 변경 리스너
    _searchController.addListener(_filterResumes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 조건에 따른 이력서 필터링
  void _filterResumes() {
    if (_sharedResumes.isEmpty) {
      setState(() {
        _filteredResumes = [];
      });
      return;
    }

    final searchQuery = _searchController.text.toLowerCase();

    // 검색어와 카테고리로 필터링
    var filtered = _sharedResumes.where((resume) {
      // 검색어 필터링
      final matchesQuery = searchQuery.isEmpty ||
          resume.title.toLowerCase().contains(searchQuery) ||
          resume.ownerName.toLowerCase().contains(searchQuery) ||
          resume.content.toLowerCase().contains(searchQuery);

      // 카테고리 필터링 (카테고리 정보가 실제 이력서 모델에 추가되어야 함)
      final matchesCategory = _selectedCategory == '전체' ||
          resume.title.contains(_selectedCategory); // 임시로 제목에 카테고리가 포함되어 있는지 확인

      return matchesQuery && matchesCategory;
    }).toList();

    // 정렬 옵션에 따른 정렬
    switch (_selectedSortOption) {
      case '최신순':
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case '오래된순':
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case '제목순':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case '작성자순':
        filtered.sort((a, b) => a.ownerName.compareTo(b.ownerName));
        break;
    }

    setState(() {
      _filteredResumes = filtered;
    });
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
        12,
        (index) => Resume(
          id: 'shared-$index',
          title: '${_getRandomCategory()} 이력서 ${index + 1}',
          content: '이력서 ${index + 1}의 내용입니다. 다양한 경력과 프로젝트 경험을 포함하고 있습니다.',
          createdAt: now.subtract(Duration(days: index * 3)),
          updatedAt: now.subtract(Duration(days: index)),
          isShared: true,
          ownerName: '사용자 ${index + 1}',
          sharingUrl: 'https://resume-share.example.com/shared-$index',
        ),
      );

      setState(() {
        _sharedResumes = sharedResumes;
        _filterResumes(); // 초기 필터링 적용
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

  // 임시 데이터 생성을 위한 랜덤 카테고리 선택
  String _getRandomCategory() {
    final categories = ['개발', '디자인', '마케팅', '기획', '영업', '인사', '기타'];
    return categories[
        DateTime.now().millisecondsSinceEpoch % categories.length];
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
    return Column(
      children: [
        // 모바일용 검색 필터 영역을 확장 패널로 변경
        ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 8),
              const Text('검색 필터'),
              const Spacer(),
              Text(
                '${_filteredResumes.length}개의 이력서',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          initiallyExpanded: false, // 기본적으로 접힌 상태로 시작
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // 검색창
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '이력서 제목, 작성자 검색',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 필터 옵션 (드롭다운)
                  Row(
                    children: [
                      // 카테고리 선택
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '카테고리',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          value: _selectedCategory,
                          items: _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                              _filterResumes();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 정렬 방식 선택
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '정렬',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          value: _selectedSortOption,
                          items: _sortOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSortOption = value!;
                              _filterResumes();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 새로고침 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadSharedResumes,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('새로고침'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 이력서 목록
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadSharedResumes,
            child: _filteredResumes.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredResumes.length,
                    itemBuilder: (context, index) {
                      final resume = _filteredResumes[index];
                      return _buildResumeCard(resume);
                    },
                  ),
          ),
        ),
      ],
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
              // 상단 타이틀 및 정보 표시줄
              Row(
                children: [
                  // 타이틀
                  const Expanded(
                    child: Text(
                      '공유된 이력서 목록',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 검색 필터 토글 버튼
                  IconButton(
                    icon: Icon(
                      _isSearchExpanded
                          ? Icons.filter_list_off
                          : Icons.filter_list,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: _isSearchExpanded ? '검색 필터 닫기' : '검색 필터 열기',
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // 결과 개수 표시
                  Text(
                    '${_filteredResumes.length}개 결과',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  // 새로고침 버튼
                  ElevatedButton.icon(
                    onPressed: _loadSharedResumes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('새로고침'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),

              // 검색 필터 영역 (토글 가능)
              if (_isSearchExpanded) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '검색 필터',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 검색창 및 필터
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 검색창
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: '이력서 제목, 작성자, 내용 검색',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 카테고리 선택
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '카테고리',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                value: _selectedCategory,
                                isExpanded: true,
                                items: _categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                    _filterResumes();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 정렬 선택
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '정렬 방식',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                value: _selectedSortOption,
                                isExpanded: true,
                                items: _sortOptions.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortOption = value!;
                                    _filterResumes();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 그리드 레이아웃의 공유 이력서 목록
              Expanded(
                child: _filteredResumes.isEmpty
                    ? const Center(
                        child: Text('검색 결과가 없습니다.',
                            style: TextStyle(fontSize: 18)))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: _filteredResumes.length,
                        itemBuilder: (context, index) {
                          final resume = _filteredResumes[index];
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      resume.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // 카테고리 칩 추가
                  _getCategoryChip(resume.title),
                ],
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
                  // 카테고리 칩
                  _getCategoryChip(resume.title),
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

  // 카테고리 칩 생성
  Widget _getCategoryChip(String title) {
    String category = '기타';
    Color chipColor = Colors.grey;

    // 제목에서 카테고리 추출 (실제로는 이력서 모델에 카테고리 필드가 있어야 함)
    if (title.contains('개발')) {
      category = '개발';
      chipColor = Colors.blue;
    } else if (title.contains('디자인')) {
      category = '디자인';
      chipColor = Colors.purple;
    } else if (title.contains('마케팅')) {
      category = '마케팅';
      chipColor = Colors.orange;
    } else if (title.contains('기획')) {
      category = '기획';
      chipColor = Colors.green;
    } else if (title.contains('영업')) {
      category = '영업';
      chipColor = Colors.red;
    } else if (title.contains('인사')) {
      category = '인사';
      chipColor = Colors.teal;
    }

    return Chip(
      label: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(0),
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
