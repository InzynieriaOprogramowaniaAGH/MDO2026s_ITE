const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Aplikacja Express.js dziala! Zaliczenie Lab 5 i 6.');
});

app.listen(PORT, () => {
  console.log(`Serwer wystartowal na porcie ${PORT}`);
});