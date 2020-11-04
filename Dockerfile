FROM centos:7
FROM java:openjdk-8-jdk AS SOAPUI

#  Version
ENV   SOAPUI_VERSION  5.5.0

# Download and unarchive SoapUI
RUN mkdir -p /opt &&\
    curl  https://s3.amazonaws.com/downloads.eviware/soapuios/${SOAPUI_VERSION}/SoapUI-${SOAPUI_VERSION}-linux-bin.tar.gz \
    | gunzip -c - | tar -xf - -C /opt && \
    ln -s /opt/SoapUI-${SOAPUI_VERSION} /opt/SoapUI

# Set working directory
WORKDIR /opt/bin

# Set environment
ENV PATH ${PATH}:/opt/SoapUI/bin

COPY project.xml /opt/
RUN mkdir /opt/soap

RUN ./wargenerator.sh -f "mocksoap.war" -d "/opt/soap/" -w true -x true project.xml

FROM tomcat:8.5.16-jre8-alpine

COPY --from=SOAPUI /opt/soap/mocksoap.war /usr/local/tomcat/webapps

EXPOSE 8080
CMD ["catalina.sh", "run"]
