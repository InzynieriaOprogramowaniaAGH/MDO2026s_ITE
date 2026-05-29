FROM node:18-alpine

WORKDIR /app

COPY nestjs-app-v15.tar.gz .

RUN tar -xzf nestjs-app-v15.tar.gz && rm nestjs-app-v15.tar.gz

ENV WERSJA=v2
EXPOSE 3000

CMD ["node", "zepsuty-plik.js"]