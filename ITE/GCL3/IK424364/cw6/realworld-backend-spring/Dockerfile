FROM eclipse-temurin:25-noble AS builder

WORKDIR app/

# Pliki gradle
COPY gradlew .
COPY gradle gradle
COPY build.gradle.ktl settings.gradle.ktl ./

RUN ./gradlew dependencies --no-daemon

COPY . .
RUN ./gradlew assemble --no-daemon


# Runner
FROM eclipse-temurin:25-jre-noble AS runner
cd      
WORKDIR app/

COPY --from=builder /app/build/libs/*.jsr app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]