FROM eclipse-temurin:25-noble AS builder

WORKDIR app/

COPY . .

RUN ./gradlew dependencies --no-daemon

COPY . .
RUN ./gradlew assemble --no-daemon


# Runner
FROM eclipse-temurin:25-jre-noble AS runner
WORKDIR app/

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
