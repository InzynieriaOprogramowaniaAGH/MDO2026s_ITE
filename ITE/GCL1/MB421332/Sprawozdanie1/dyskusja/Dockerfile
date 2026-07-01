FROM maven:3.9.6-eclipse-temurin-17 AS builder
RUN apt-get update && apt-get install -y git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/mymaven
RUN git clone https://github.com/stleary/JSON-java.git .
RUN mvn package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /usr/src/mymaven/target/*.jar /app/json-library.jar
CMD ["java", "-jar", "/app/json-library.jar"]