const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('<h1>Aktualizacja udana! - To jest Wersja: v1</h1>');
});

app.listen(port, () => {
  console.log(`Aplikacja v2 dziala na porcie ${port}`);
});