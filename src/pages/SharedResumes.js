import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Card,
  CardContent,
  CardActions,
  Container,
  Grid,
  Typography,
  Button,
  Chip,
  Avatar,
} from '@mui/material';
import {
  Visibility as VisibilityIcon,
  RateReview as ReviewIcon,
} from '@mui/icons-material';

const SharedResumes = () => {
  const navigate = useNavigate();
  const [sharedResumes, setSharedResumes] = useState([]);

  useEffect(() => {
    // TODO: 공유된 이력서 목록 API 연동
    const fetchSharedResumes = async () => {
      try {
        // 임시 데이터
        setSharedResumes([
          {
            id: 1,
            title: '프론트엔드 개발자 이력서',
            author: '홍길동',
            sharedAt: '2024-03-15',
            tags: ['프론트엔드', 'React', 'TypeScript'],
          },
          {
            id: 2,
            title: '백엔드 개발자 이력서',
            author: '김철수',
            sharedAt: '2024-03-14',
            tags: ['백엔드', 'Java', 'Spring'],
          },
        ]);
      } catch (error) {
        console.error('공유된 이력서 목록 조회 실패:', error);
      }
    };

    fetchSharedResumes();
  }, []);

  const handleView = (id) => {
    navigate(`/viewer/${id}`);
  };

  const handleRequestReview = (id) => {
    // TODO: 리뷰 요청 API 연동
    console.log('리뷰 요청:', id);
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          공유된 이력서
        </Typography>
        <Typography variant="body1" color="text.secondary">
          다른 사용자들과 공유된 이력서를 확인하고 피드백을 남겨보세요.
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {sharedResumes.map((resume) => (
          <Grid item xs={12} md={6} key={resume.id}>
            <Card>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <Avatar sx={{ mr: 2 }}>{resume.author[0]}</Avatar>
                  <Box>
                    <Typography variant="h6" component="h2">
                      {resume.title}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {resume.author} • {resume.sharedAt}
                    </Typography>
                  </Box>
                </Box>
                <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                  {resume.tags.map((tag) => (
                    <Chip key={tag} label={tag} size="small" />
                  ))}
                </Box>
              </CardContent>
              <CardActions>
                <Button
                  startIcon={<VisibilityIcon />}
                  onClick={() => handleView(resume.id)}
                >
                  보기
                </Button>
                <Button
                  startIcon={<ReviewIcon />}
                  onClick={() => handleRequestReview(resume.id)}
                >
                  리뷰 요청
                </Button>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
};

export default SharedResumes; 