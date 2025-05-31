# Use a lightweight JDK 24 base image
FROM eclipse-temurin:24-jdk as builder

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR into the container
COPY build/libs/cloud-app-0.0.1-SNAPSHOT.jar app.jar

# Expose port 8080 (the default Spring Boot port)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]


# FROM openjdk:17-slim

# RUN apt-get update && apt-get install -y bash dos2unix && rm -rf /var/lib/apt/lists/*

# WORKDIR /app

# COPY . .

# RUN chmod +x ./gradlew

# RUN dos2unix gradlew

# RUN ls -la . && bash ./gradlew --version

# RUN bash ./gradlew bootJar

# EXPOSE 8080

# ENTRYPOINT ["java", "-jar", "./build/libs/cloud-app-0.0.1-SNAPSHOT.jar"]
