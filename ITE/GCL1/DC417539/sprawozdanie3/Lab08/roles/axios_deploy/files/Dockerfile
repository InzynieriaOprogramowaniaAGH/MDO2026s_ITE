FROM node:20-alpine

WORKDIR /app

COPY axios-1.20.0.tgz .
COPY verify-axios.js .

RUN npm install ./axios-1.20.0.tgz

CMD ["node", "verify-axios.js"]
