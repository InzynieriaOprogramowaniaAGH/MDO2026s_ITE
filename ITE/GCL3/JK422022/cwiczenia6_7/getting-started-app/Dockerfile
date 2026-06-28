FROM node:18-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y python3 make g++
COPY package.json yarn.lock* ./
RUN npm install
COPY . .

FROM node:18-slim AS production
WORKDIR /app
RUN apt-get update && apt-get install -y python3 make g++
COPY --from=builder /app/package.json ./
RUN npm install --omit=dev
COPY --from=builder /app/src ./src
COPY --from=builder /app/spec ./spec
EXPOSE 3000
CMD ["node", "src/index.js"]
