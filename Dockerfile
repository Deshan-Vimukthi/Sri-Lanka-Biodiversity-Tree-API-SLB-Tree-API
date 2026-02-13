# Use official OpenJDK 19 image
FROM eclipse-temurin:19-jdk

# Set working directory
WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

# Copy source code
COPY src ./src

# Make gradlew executable
RUN chmod +x ./gradlew

# Build the Spring Boot jar
RUN ./gradlew clean bootJar

# Expose application port
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "build/libs/slb-tree-api-0.0.1-SNAPSHOT.jar"]
