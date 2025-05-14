import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  Typography,
  Container,
} from '@mui/material';
import {
  Add as AddIcon,
  Share as ShareIcon,
} from '@mui/icons-material';

const Home = () => {
  const navigate = useNavigate();

  const features = [
    {
      title: '새 이력서 작성',
      description: '마크다운 에디터를 사용하여 이력서를 작성해보세요.',
      icon: <AddIcon sx={{ fontSize: 40 }} />,
      action: () => navigate('/editor'),
    },
    {
      title: '공유된 이력서',
      description: '다른 사용자들과 공유된 이력서를 확인해보세요.',
      icon: <ShareIcon sx={{ fontSize: 40 }} />,
      action: () => navigate('/shared'),
    },
  ];

  return (
    <Container maxWidth="lg">
      <Box sx={{ mt: 4, mb: 8 }}>
        <Typography variant="h3" component="h1" gutterBottom align="center">
          이력서 어디서나
        </Typography>
        <Typography variant="h5" component="h2" gutterBottom align="center" color="text.secondary">
          마크다운으로 작성하고, 어디서나 공유하세요
        </Typography>
      </Box>

      <Grid container spacing={4}>
        {features.map((feature) => (
          <Grid item xs={12} md={4} key={feature.title}>
            <Card
              sx={{
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                '&:hover': {
                  boxShadow: 6,
                  cursor: 'pointer',
                },
              }}
              onClick={feature.action}
            >
              <CardContent sx={{ flexGrow: 1, textAlign: 'center' }}>
                <Box sx={{ mb: 2 }}>{feature.icon}</Box>
                <Typography gutterBottom variant="h5" component="h2">
                  {feature.title}
                </Typography>
                <Typography color="text.secondary">
                  {feature.description}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Box sx={{ mt: 8, textAlign: 'center' }}>
        <Button
          variant="contained"
          size="large"
          startIcon={<AddIcon />}
          onClick={() => navigate('/editor')}
        >
          새 이력서 작성하기
        </Button>
      </Box>
    </Container>
  );
};

export default Home; 