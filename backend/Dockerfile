# syntax=docker/dockerfile:1.7

FROM eclipse-temurin:21.0.11_10-jdk-jammy@sha256:dbfd085220ae632a0830166e443747d1ee89e9038d92e3b48c3e5e9d8292b9a7 AS build

WORKDIR /workspace

COPY .mvn .mvn
COPY mvnw pom.xml ./

RUN chmod +x mvnw \
    && ./mvnw -B -ntp -DskipTests dependency:go-offline

COPY src src

RUN ./mvnw -B -ntp -DskipTests package \
    && cp target/backend-0.0.1-SNAPSHOT.jar /workspace/app.jar

FROM eclipse-temurin:21.0.11_10-jre-jammy@sha256:8208b3a3733529f42c4b565bfcbf16d914eb628f3ead8488b6b4d6363fcbe7cf AS runtime

RUN groupadd --system --gid 10001 appuser \
    && useradd \
        --system \
        --uid 10001 \
        --gid appuser \
        --no-create-home \
        --shell /usr/sbin/nologin \
        appuser

WORKDIR /app

COPY --from=build --chown=10001:10001 /workspace/app.jar /app/app.jar

USER 10001:10001

EXPOSE 8080

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-Djava.io.tmpdir=/tmp", "-jar", "/app/app.jar"]
