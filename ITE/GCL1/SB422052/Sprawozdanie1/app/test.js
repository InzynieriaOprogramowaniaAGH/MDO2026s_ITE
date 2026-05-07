const request = require('supertest');
const assert = require('assert');
const app = require('./server.js');

describe('Prawdziwe Testy API Express', () => {
  
  it('GET / powinien zwrócić status 200 i poprawny JSON', (done) => {
    request(app)
      .get('/')
      .expect('Content-Type', /json/) 
      .expect(200)                    
      .end((err, res) => {
        if (err) return done(err);
        
        assert.strictEqual(res.body.status, 'sukces');
        done();
      });
  });

  it('GET /health powinien zwrócić kod 200 i tekst "OK"', (done) => {
    request(app)
      .get('/health')
      .expect(200)
      .expect('OK', done);
  });

});