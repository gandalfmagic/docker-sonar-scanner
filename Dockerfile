# gandalfmagic/sonar-scanner:1.0.1
FROM alpine:3.12.1 AS build

RUN apk update && apk add wget unzip && rm -rf /var/cache/apk/* && \
    wget --quiet -O /tmp/sonar-scanner-cli-linux.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-linux.zip && \
    cd /tmp/ && unzip sonar-scanner-cli-linux.zip && \
    mv /tmp/sonar-scanner-4.5.0.2216-linux /tmp/sonar-scanner && \
    sed -i 's/^use_embedded_jre=true.*/use_embedded_jre=false/' /tmp/sonar-scanner/bin/sonar-scanner

FROM adoptopenjdk/openjdk11-openj9:x86_64-alpine-jre-11.0.9_11_openj9-0.23.0

ENV PATH="${PATH}:/opt/sonar-scanner/bin"
ENV JAVA_HOME="/opt/java/openjdk"

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/* && \
    adduser app -D -h /app

WORKDIR /app

COPY --from=build /tmp/sonar-scanner/lib /opt/sonar-scanner/lib
COPY --from=build /tmp/sonar-scanner/conf /opt/sonar-scanner/conf
COPY --from=build /tmp/sonar-scanner/bin /opt/sonar-scanner/bin

USER app
