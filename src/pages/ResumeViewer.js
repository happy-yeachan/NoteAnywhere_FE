import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Paper,
  Typography,
  Button,
  IconButton,
  Tooltip,
  Divider,
  TextField,
} from '@mui/material';
import {
  ArrowBack as ArrowBackIcon,
  Share as ShareIcon,
  RateReview as ReviewIcon,
  Download as DownloadIcon,
} from '@mui/icons-material';
import ReactMarkdown from 'react-markdown';

const ResumeViewer = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [resume, setResume] = useState(null);
  const [comments, setComments] = useState([]);
  const [commentInput, setCommentInput] = useState('');

  useEffect(() => {
    // TODO: 이력서 상세 조회 API 연동
    const fetchResume = async () => {
      try {
        // 임시 데이터
        setResume({
          id: id,
          title: '프론트엔드 개발자 이력서',
          author: '홍길동',
          content: `# 홍길동
## 프론트엔드 개발자

### 기술 스택
- React
- TypeScript
- Next.js
- Material-UI

### 경력
- ABC 회사 (2020-2023)
  - React 기반 웹 애플리케이션 개발
  - 성능 최적화 및 코드 품질 개선

### 교육
- XYZ 대학교 컴퓨터공학과 (2016-2020)`,
          sharedAt: '2024-03-15',
        });
      } catch (error) {
        console.error('이력서 조회 실패:', error);
      }
    };

    fetchResume();

    // TODO: 댓글 목록 API 연동
    setComments([
      { id: 1, author: '김리액트', content: '좋은 이력서네요!', createdAt: '2024-03-16' },
      { id: 2, author: '박코드', content: '프로젝트 경험이 인상적입니다.', createdAt: '2024-03-16' },
    ]);
  }, [id]);

  const handleBack = () => {
    navigate(-1);
  };

  const handleShare = async () => {
    try {
      // TODO: 이력서 공유 API 연동
      console.log('이력서 공유');
    } catch (error) {
      console.error('이력서 공유 실패:', error);
    }
  };

  const handleRequestReview = async () => {
    try {
      // TODO: 리뷰 요청 API 연동
      console.log('리뷰 요청');
    } catch (error) {
      console.error('리뷰 요청 실패:', error);
    }
  };

  const handleDownload = async () => {
    try {
      // TODO: PDF 다운로드 API 연동
      console.log('PDF 다운로드');
    } catch (error) {
      console.error('PDF 다운로드 실패:', error);
    }
  };

  const handleAddComment = () => {
    if (!commentInput.trim()) return;
    // TODO: 댓글 등록 API 연동
    setComments([
      ...comments,
      {
        id: comments.length + 1,
        author: '나',
        content: commentInput,
        createdAt: new Date().toISOString().slice(0, 10),
      },
    ]);
    setCommentInput('');
  };

  if (!resume) {
    return (
      <Container>
        <Typography>로딩 중...</Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="md">
      <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <IconButton onClick={handleBack}>
          <ArrowBackIcon />
        </IconButton>
        <Typography variant="h4" component="h1">
          {resume.title}
        </Typography>
      </Box>

      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="body1" color="text.secondary">
          작성자: {resume.author} • 공유일: {resume.sharedAt}
        </Typography>
        <Box>
          <Tooltip title="공유하기">
            <IconButton onClick={handleShare}>
              <ShareIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="리뷰 요청">
            <IconButton onClick={handleRequestReview}>
              <ReviewIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="PDF 다운로드">
            <IconButton onClick={handleDownload}>
              <DownloadIcon />
            </IconButton>
          </Tooltip>
        </Box>
      </Box>

      <Divider sx={{ mb: 3 }} />

      <Paper sx={{ p: 4 }}>
        <ReactMarkdown>{resume.content}</ReactMarkdown>
      </Paper>

      {/* 댓글 영역 */}
      <Box sx={{ mb: 2 }}>
        <Typography variant="h6" gutterBottom>댓글</Typography>
        {comments.length === 0 && (
          <Typography color="text.secondary">아직 댓글이 없습니다.</Typography>
        )}
        {comments.map((c) => (
          <Box key={c.id} sx={{ mb: 1, p: 1, borderBottom: '1px solid #eee' }}>
            <Typography variant="subtitle2">{c.author} <span style={{color:'#888', fontSize:12}}>{c.createdAt}</span></Typography>
            <Typography variant="body2">{c.content}</Typography>
          </Box>
        ))}
        <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
          <TextField
            fullWidth
            size="small"
            placeholder="댓글을 입력하세요..."
            value={commentInput}
            onChange={e => setCommentInput(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleAddComment(); } }}
          />
          <Button variant="contained" onClick={handleAddComment}>등록</Button>
        </Box>
      </Box>
    </Container>
  );
};

export default ResumeViewer; 