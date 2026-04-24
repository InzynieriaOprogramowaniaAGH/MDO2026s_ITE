
FROM node:18-slim

WORKDIR /app

COPY . .

RUN if [ -f "package.json" ]; then npm install; fi

EXPOSE 3000

CMD ["bash"]