FROM python:3.12-slim

WORKDIR /opt/app

# 1. Instalujemy Twoją paczkę z PyPI zamiast npm
RUN pip install --no-cache-dir olo-devopsowo-lab7

# 2. Tworzymy plik uruchomieniowy (dokładnie tak, jak w Twoim Jenkinsfile)
RUN printf "from flask import Flask\n\
app = Flask(__name__)\n\
@app.route('/')\n\
def hello(): return '<h1>Działa bezpośrednio z PyPI!</h1>'\n\
if __name__ == '__main__': app.run(host='0.0.0.0', port=5000)\n" > app.py

# 3. Zmieniamy port na 5000 (standard dla Flaska)
EXPOSE 5000

# 4. Odpalamy aplikację skryptem pythonowym
CMD ["python", "app.py"]