import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Button, Container, Typography, Paper } from '@mui/material';
import GoogleIcon from '@mui/icons-material/Google';
import GitHubIcon from '@mui/icons-material/GitHub';

const Login = () => {
  const navigate = useNavigate();

  const handleGoogleLogin = async () => {
    // TODO: Google OAuth 연동
    try {
      // Google 로그인 로직 구현
      navigate('/');
    } catch (error) {
      console.error('Google 로그인 실패:', error);
    }
  };

  const handleGithubLogin = async () => {
    // TODO: GitHub OAuth 연동
    try {
      // GitHub 로그인 로직 구현
      navigate('/');
    } catch (error) {
      console.error('GitHub 로그인 실패:', error);
    }
  };

  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          marginTop: 8,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Paper
          elevation={3}
          sx={{
            padding: 4,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
          }}
        >
          <Typography component="h1" variant="h5" sx={{ mb: 3 }}>
            이력서 어디서나
          </Typography>
          <Typography variant="body1" sx={{ mb: 3, textAlign: 'center' }}>
            소셜 계정으로 간편하게 로그인하세요
          </Typography>
          <Button
            fullWidth
            variant="contained"
            startIcon={<GoogleIcon />}
            onClick={handleGoogleLogin}
            sx={{ mb: 2, backgroundColor: '#DB4437' }}
          >
            Google로 로그인
          </Button>
          <Button
            fullWidth
            variant="contained"
            startIcon={<GitHubIcon />}
            onClick={handleGithubLogin}
            sx={{ backgroundColor: '#333' }}
          >
            GitHub로 로그인
          </Button>
        </Paper>
      </Box>
    </Container>
  );
};

export default Login; 