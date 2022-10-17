FROM adoptopenjdk/openjdk8:latest
VOLUME /tmp
WORKDIR /usr/app
COPY complete/target/spring-boot-complete-1.0.0.jar /usr/app
RUN sh -c 'touch spring-boot-complete-1.0.0.jar'
EXPOSE 8080
ENTRYPOINT ["java","-jar","spring-boot-complete-1.0.0.jar"]
