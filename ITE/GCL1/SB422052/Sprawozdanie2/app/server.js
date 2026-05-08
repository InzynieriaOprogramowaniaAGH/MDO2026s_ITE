const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;


app.get('/', (req, res) => {
  
  console.log(`[${new Date().toISOString()}]  Otrzymano zapytanie GET na endpoint główny '/'`);
  
  res.json({
    wiadomosc: 'Kod uruchamia się z folderu app',
    status: 'sukces'
  });
});

// Endpoint Healthcheck
app.get('/health', (req, res) => {
  // Logujemy sprawdzenie statusu zdrowia
  console.log(`[${new Date().toISOString()}] Otrzymano zapytanie GET na endpoint '/health' (Healthcheck)`);
  
  res.status(200).send('OK');
});


if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Serwer nasłuchuje na porcie ${PORT}`);
  });
}


module.exports = app;