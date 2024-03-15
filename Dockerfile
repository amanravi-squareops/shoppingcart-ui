
FROM fabric8/java-alpine-openjdk8-jre

WORKDIR /application

RUN apk --no-cache add maven openjdk8

COPY . /application
RUN mvn clean package -DskipTests=true

ENV JAR_FILE_NAME=shoppingcart-ui-0.0.1-SNAPSHOT-exec.jar
RUN cp /application/target/$JAR_FILE_NAME app-new.jar

ENV JAVA_APP_JAR=app-new.jar

EXPOSE 8080 8787

ENV JAVA_OPTS="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8787,suspend=n"
RUN sh -c 'touch /app-new.jar'

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=docker -jar $JAVA_APP_JAR"]



