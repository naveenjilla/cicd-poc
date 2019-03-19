FROM openjdk:8-jdk-alpine
COPY target/gs-spring-boot-docker-0.1.0.jar my-app.jar
WORKDIR /
CMD java -jar my-app.jar
EXPOSE 8080
