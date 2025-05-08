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
