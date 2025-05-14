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
  useMediaQuery,
  useTheme,
  Fab,
} from '@mui/material';
import {
  Save as SaveIcon,
  Preview as PreviewIcon,
  Share as ShareIcon,
  Help as HelpIcon,
  Edit as EditIcon,
} from '@mui/icons-material';
import ReactMarkdown from 'react-markdown';
import styled from '@emotion/styled';

const EditorContainer = styled(Box)`
  display: flex;
  flex-direction: ${({ isSmallScreen }) => isSmallScreen ? 'column' : 'row'};
  gap: 24px;
  width: 100%;
  margin-top: 16px;
`;

const Editor = styled(TextField)`
  width: 100%;
  flex: 1;
  & .MuiInputBase-root {
    font-family: 'Consolas', monospace;
    height: ${({ height }) => height || '600px'};
    overflow: hidden;
  }
  & .MuiInputBase-input {
    height: 100% !important;
    overflow-y: auto !important;
    padding: 16px;
    line-height: 1.6;
    font-size: 16px;
  }
  & .MuiInputBase-inputMultiline {
    height: 100% !important;
  }
`;

const Preview = styled(Paper)`
  width: 100%;
  flex: 1;
  padding: 20px;
  height: ${({ height }) => height || '600px'};
  overflow-y: auto;
  line-height: 1.6;
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  
  // 마크다운 스타일링 개선
  & h1, & h2, & h3, & h4, & h5, & h6 {
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    font-weight: 600;
  }
  & h1 {
    font-size: 1.8em;
    border-bottom: 1px solid #eaecef;
    padding-bottom: 0.3em;
  }
  & h2 {
    font-size: 1.5em;
    border-bottom: 1px solid #eaecef;
    padding-bottom: 0.3em;
  }
  & ul, & ol {
    padding-left: 2em;
    margin-bottom: 1em;
  }
  & p {
    margin-bottom: 1em;
  }
  & code {
    background-color: rgba(0, 0, 0, 0.05);
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-family: 'Consolas', monospace;
  }
  & blockquote {
    border-left: 4px solid #ddd;
    padding-left: 1em;
    color: #666;
    margin-left: 0;
  }
  & a {
    color: #0366d6;
    text-decoration: none;
  }
  & a:hover {
    text-decoration: underline;
  }
  & table {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 1em;
  }
  & th, & td {
    border: 1px solid #ddd;
    padding: 8px;
  }
  & th {
    background-color: #f6f8fa;
  }
`;

const HelpCard = styled(Card)`
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 400px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
`;

const ButtonContainer = styled(Box)`
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  justify-content: flex-end;
`;

const FloatingFab = styled(Fab)`
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 100;
`;

const ResumeEditor = () => {
  const navigate = useNavigate();
  const theme = useTheme();
  const isSmallScreen = useMediaQuery(theme.breakpoints.down('md'));
  const isMobileScreen = useMediaQuery(theme.breakpoints.down('sm'));
  
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [showHelp, setShowHelp] = useState(false);
  const [saveStatus, setSaveStatus] = useState('saved');
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [isEditMode, setIsEditMode] = useState(true);

  // 편집기 및 미리보기 영역의 높이 계산
  const editorHeight = isMobileScreen ? '400px' : isSmallScreen ? '500px' : '600px';

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
    { key: '```', description: '코드 블록' },
    { key: '> 텍스트', description: '인용문' },
    { key: '---', description: '수평선' },
    { key: '| 헤더1 | 헤더2 |', description: '테이블 시작' },
  ];

  // 미리보기 모드 토글 핸들러
  const togglePreviewMode = () => {
    setIsEditMode(!isEditMode);
  };

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <Box sx={{ 
          display: 'flex', 
          flexDirection: isSmallScreen ? 'column' : 'row', 
          justifyContent: 'space-between', 
          alignItems: isSmallScreen ? 'flex-start' : 'center',
          gap: 2
        }}>
          <Typography variant="h4" component="h1" gutterBottom={isSmallScreen}>
            이력서 작성
          </Typography>
          
          <ButtonContainer>
            <Typography variant="body2" color="text.secondary" sx={{ mr: 1 }}>
              {saveStatus === 'saving' ? '저장 중...' : saveStatus === 'saved' ? '저장됨' : '저장 실패'}
            </Typography>
            
            <Tooltip title="마크다운 도움말">
              <IconButton onClick={() => setShowHelp(true)} color="primary">
                <HelpIcon />
              </IconButton>
            </Tooltip>
            
            <Tooltip title="공유하기">
              <Button
                variant="outlined"
                color="primary"
                startIcon={<ShareIcon />}
                onClick={handleShare}
                size={isSmallScreen ? "small" : "medium"}
              >
                공유
              </Button>
            </Tooltip>
            
            <Button
              variant="contained"
              color="primary"
              startIcon={<SaveIcon />}
              onClick={handleSave}
              size={isSmallScreen ? "small" : "medium"}
            >
              저장
            </Button>
          </ButtonContainer>
        </Box>

        <TextField
          fullWidth
          label="이력서 제목"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          sx={{ mb: 2 }}
          placeholder="이력서 제목을 입력해주세요"
          variant="outlined"
        />

        {isSmallScreen ? (
          <>
            {isEditMode ? (
              <Editor
                fullWidth
                multiline
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="마크다운 형식으로 이력서 내용을 작성해주세요"
                variant="outlined"
                height={editorHeight}
              />
            ) : (
              <Preview height={editorHeight}>
                {content ? (
                  <ReactMarkdown>{content}</ReactMarkdown>
                ) : (
                  <Typography color="text.secondary" sx={{ fontStyle: 'italic' }}>
                    미리보기할 내용이 없습니다. 내용을 입력해주세요.
                  </Typography>
                )}
              </Preview>
            )}
            
            {/* 플로팅 미리보기/편집 전환 버튼 */}
            <FloatingFab 
              color={isEditMode ? "primary" : "secondary"}
              aria-label={isEditMode ? "미리보기" : "편집"}
              onClick={togglePreviewMode}
              size="medium"
            >
              {isEditMode ? <PreviewIcon /> : <EditIcon />}
            </FloatingFab>
          </>
        ) : (
          <EditorContainer isSmallScreen={isSmallScreen}>
            <Editor
              fullWidth
              multiline
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="마크다운 형식으로 이력서 내용을 작성해주세요"
              variant="outlined"
              height={editorHeight}
            />
            <Preview height={editorHeight}>
              {content ? (
                <ReactMarkdown>{content}</ReactMarkdown>
              ) : (
                <Typography color="text.secondary" sx={{ fontStyle: 'italic' }}>
                  미리보기할 내용이 없습니다. 내용을 입력해주세요.
                </Typography>
              )}
            </Preview>
          </EditorContainer>
        )}

        {showHelp && (
          <Box sx={{ 
            position: 'fixed', 
            top: 0, 
            left: 0, 
            right: 0, 
            bottom: 0, 
            bgcolor: 'rgba(0,0,0,0.5)', 
            zIndex: 999,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }} onClick={() => setShowHelp(false)}>
            <HelpCard onClick={(e) => e.stopPropagation()}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  마크다운 사용법
                </Typography>
                <Divider sx={{ mb: 2 }} />
                <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 1 }}>
                  {markdownShortcuts.map((shortcut) => (
                    <React.Fragment key={shortcut.key}>
                      <Box>
                        <Typography 
                          component="code" 
                          sx={{ 
                            bgcolor: 'grey.100', 
                            p: '4px 8px', 
                            borderRadius: 1,
                            fontFamily: 'monospace',
                            display: 'inline-block'
                          }}
                        >
                          {shortcut.key}
                        </Typography>
                      </Box>
                      <Box>
                        <Typography variant="body2">
                          {shortcut.description}
                        </Typography>
                      </Box>
                    </React.Fragment>
                  ))}
                </Box>
                <Box sx={{ mt: 3, textAlign: 'right' }}>
                  <Button variant="contained" onClick={() => setShowHelp(false)}>
                    닫기
                  </Button>
                </Box>
              </CardContent>
            </HelpCard>
          </Box>
        )}

        <Snackbar
          open={snackbar.open}
          autoHideDuration={3000}
          onClose={() => setSnackbar({ ...snackbar, open: false })}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        >
          <Alert 
            severity={snackbar.severity} 
            onClose={() => setSnackbar({ ...snackbar, open: false })}
            variant="filled"
            elevation={6}
          >
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Box>
    </Container>
  );
};

export default ResumeEditor;