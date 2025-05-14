import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Button,
  Container,
  Paper,
  TextField,
  Typography,
  IconButton,
  Tooltip,
  Snackbar,
  Alert,
  Divider,
  Card,
  CardContent,
} from '@mui/material';
import {
  Save as SaveIcon,
  Preview as PreviewIcon,
  Share as ShareIcon,
  Help as HelpIcon,
} from '@mui/icons-material';
import ReactMarkdown from 'react-markdown';
import styled from '@emotion/styled';

const EditorContainer = styled(Box)`
  display: flex;
  gap: 20px;
  height: calc(100vh - 200px);
`;

const Editor = styled(TextField)`
  flex: 1;
  & .MuiInputBase-root {
    height: 100%;
    font-family: 'Consolas', monospace;
  }
  & .MuiInputBase-input {
    height: 100% !important;
    overflow-y: auto;
    line-height: 1.6;
    padding: 20px;
  }
`;

const Preview = styled(Paper)`
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  line-height: 1.6;
`;

const HelpCard = styled(Card)`
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 400px;
  max-width: 90vw;
  z-index: 1000;
`;

const ResumeEditor = () => {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [isPreview, setIsPreview] = useState(false);
  const [showHelp, setShowHelp] = useState(false);
  const [saveStatus, setSaveStatus] = useState('saved'); // 'saved', 'saving', 'error'
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  // 자동 저장 기능
  useEffect(() => {
    const autoSave = async () => {
      if (content.trim() === '') return;
      
      setSaveStatus('saving');
      try {
        // TODO: 자동 저장 API 연동
        await new Promise(resolve => setTimeout(resolve, 500)); // 임시 지연
        setSaveStatus('saved');
      } catch (error) {
        setSaveStatus('error');
        setSnackbar({
          open: true,
          message: '자동 저장 실패',
          severity: 'error'
        });
      }
    };

    const timeoutId = setTimeout(autoSave, 2000);
    return () => clearTimeout(timeoutId);
  }, [content]);

  const handleSave = async () => {
    if (!title.trim()) {
      setSnackbar({
        open: true,
        message: '제목을 입력해주세요',
        severity: 'warning'
      });
      return;
    }

    setSaveStatus('saving');
    try {
      // TODO: 이력서 저장 API 연동
      await new Promise(resolve => setTimeout(resolve, 500)); // 임시 지연
      setSaveStatus('saved');
      setSnackbar({
        open: true,
        message: '저장되었습니다',
        severity: 'success'
      });
    } catch (error) {
      setSaveStatus('error');
      setSnackbar({
        open: true,
        message: '저장 실패',
        severity: 'error'
      });
    }
  };

  const handleShare = async () => {
    if (!title.trim() || !content.trim()) {
      setSnackbar({
        open: true,
        message: '제목과 내용을 모두 입력해주세요',
        severity: 'warning'
      });
      return;
    }

    try {
      // TODO: 이력서 공유 API 연동
      setSnackbar({
        open: true,
        message: '공유 링크가 생성되었습니다',
        severity: 'success'
      });
    } catch (error) {
      setSnackbar({
        open: true,
        message: '공유 실패',
        severity: 'error'
      });
    }
  };

  const markdownShortcuts = [
    { key: '#', description: '제목 (H1)' },
    { key: '##', description: '부제목 (H2)' },
    { key: '###', description: '소제목 (H3)' },
    { key: '**텍스트**', description: '굵게' },
    { key: '*텍스트*', description: '기울임' },
    { key: '- 항목', description: '글머리 기호' },
    { key: '1. 항목', description: '번호 매기기' },
    { key: '[링크](URL)', description: '링크' },
  ];

  return (
    <Container maxWidth="xl">
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4" component="h1">
          이력서 작성
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Typography variant="body2" color="text.secondary" sx={{ mr: 1 }}>
            {saveStatus === 'saving' ? '저장 중...' : saveStatus === 'saved' ? '저장됨' : '저장 실패'}
          </Typography>
          <Tooltip title="마크다운 도움말">
            <IconButton onClick={() => setShowHelp(true)}>
              <HelpIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="미리보기">
            <IconButton onClick={() => setIsPreview(!isPreview)}>
              <PreviewIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="공유하기">
            <IconButton onClick={handleShare}>
              <ShareIcon />
            </IconButton>
          </Tooltip>
          <Button
            variant="contained"
            startIcon={<SaveIcon />}
            onClick={handleSave}
            sx={{ ml: 1 }}
          >
            저장
          </Button>
        </Box>
      </Box>

      <TextField
        fullWidth
        label="이력서 제목"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        sx={{ mb: 2 }}
        placeholder="이력서 제목을 입력하세요"
      />

      <EditorContainer>
        <Editor
          multiline
          fullWidth
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="마크다운으로 이력서를 작성해보세요..."
          variant="outlined"
          sx={{ display: isPreview ? 'none' : 'block' }}
        />
        <Preview sx={{ display: isPreview ? 'block' : 'none' }}>
          <ReactMarkdown>{content}</ReactMarkdown>
        </Preview>
      </EditorContainer>

      {showHelp && (
        <HelpCard>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              마크다운 단축키
            </Typography>
            <Divider sx={{ mb: 2 }} />
            {markdownShortcuts.map((shortcut) => (
              <Box key={shortcut.key} sx={{ mb: 1 }}>
                <Typography variant="subtitle2" component="code" sx={{ bgcolor: 'grey.100', p: 0.5, borderRadius: 1 }}>
                  {shortcut.key}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {shortcut.description}
                </Typography>
              </Box>
            ))}
            <Box sx={{ mt: 2, textAlign: 'right' }}>
              <Button onClick={() => setShowHelp(false)}>닫기</Button>
            </Box>
          </CardContent>
        </HelpCard>
      )}

      <Snackbar
        open={snackbar.open}
        autoHideDuration={3000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity} onClose={() => setSnackbar({ ...snackbar, open: false })}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default ResumeEditor; 