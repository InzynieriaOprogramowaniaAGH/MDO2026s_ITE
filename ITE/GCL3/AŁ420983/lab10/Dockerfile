FROM python:3.12-slim

WORKDIR /opt/app

RUN pip install --no-cache-dir olo-devopsowo-lab7

RUN printf "from flask import Flask\n\
raise Exception('Celowy blad aplikacji')\n\
app = Flask(__name__)\n\
@app.route('/')\n\
def hello(): return '<h1>Działa ELO!</h1>'\n\
if __name__ == '__main__': app.run(host='0.0.0.0', port=5000)\n" > app.py

EXPOSE 5000

CMD ["python", "app.py"]