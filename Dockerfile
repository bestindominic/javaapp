FROM ubuntu:16.04

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle
ENV LANG            en_US.UTF-8
ENV LC_ALL          en_US.UTF-8

RUN apt-get update && \
  apt-get install -y --no-install-recommends locales && \
  locale-gen en_US.UTF-8 && \
  apt-get dist-upgrade -y && \
  apt-get --purge remove openjdk* && \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
  apt-get update && \
  apt-get install -y --no-install-recommends oracle-java8-installer oracle-java8-set-default && \
  apt-get clean all

RUN wget --no-verbose -O /tmp/apache-maven-3.5.3-bin.tar.gz http://archive.apache.org/dist/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz && \
    tar xzf /tmp/apache-maven-3.5.3-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.5.3 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin  && \
    rm -f /tmp/apache-maven-3.5.3-bin.tar.gz

ENV MAVEN_HOME /opt/maven

RUN cd /opt && wget http://archive.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.tar.gz && tar -xvf /opt/apache-tomcat-9.0.8.tar.gz
RUN rm -rf /opt/apache-tomcat-9.0.8/webapps/*

ADD . /app

RUN cd /app/complete && mvn clean compile
RUN cd  /app/complete && mvn package
RUN cp -r /app/target/omsservice.war /opt/apache-tomcat-9.0.8/webapps

EXPOSE 8081

CMD ["/opt/apache-tomcat-9.0.8/bin/catalina.sh", "run"]
