const express = require('express');

const app = express();

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from DevOps Platform on EKS!');
});

app.get('/health', (req, res) => {
  res.json({
    status: 'Up',
  });
});

app.listen(PORT, () => {
  console.log(`Aplication running on port ${PORT}`);
});
