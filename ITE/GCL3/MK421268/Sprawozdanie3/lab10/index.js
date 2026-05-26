const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('<h1>Aktualizacja udana! - To jest Wersja: v2</h1><p>Dodano nowe funkcje.</p>');
});

app.listen(port, () => {
  console.log(`Aplikacja v2 dziala na porcie ${port}`);
});