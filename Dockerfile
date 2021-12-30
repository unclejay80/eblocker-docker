FROM maven:3.8.3-adoptopenjdk-11

VOLUME ["/redis"]
VOLUME ["/opt/eblocker-icap"]
VOLUME ["/opt/eblocker-network"]
VOLUME ["/opt/eblocker-lists"]

EXPOSE 3000

ENV RELEASE=2.8

RUN apt-get -qq update \
  && apt-get install -qqy --no-install-recommends \
  git-core \
  unzip \
  build-essential \
  redis \
  net-tools \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download repos
RUN mkdir -p /src 

RUN git clone https://github.com/eblocker/eblocker-top.git /src/eblocker-top
RUN git clone https://github.com/eblocker/eblocker-crypto.git /src/eblocker-crypto
RUN git clone https://github.com/eblocker/eblocker-registration-api.git /src/eblocker-registration-api
RUN git clone https://github.com/eblocker/eblocker-lists.git /src/eblocker-lists
RUN git clone https://github.com/eblocker/netty-icap.git /src/netty-icap
RUN git clone https://github.com/eblocker/eblocker.git /src/eblocker


# install & build packages
RUN cd /src/eblocker-top && mvn install
RUN cd /src/eblocker-crypto && mvn install
RUN cd /src/eblocker-registration-api && mvn install
RUN cd /src/netty-icap && mvn install
RUN cd /src/eblocker && mvn install  -DskipTests


# fix for eblocker-lists build - dependency version must be changed otherwise mvn install for 
RUN awk -v RS="</dependency>" '/<groupId>org.eblocker<\/groupId>/ {sub(/2\.7\.4/, "2.9-SNAPSHOT")} {printf "%s", $0 RS}' /src/eblocker-lists/pom.xml  >  /src/eblocker-lists/test_pom.xml
RUN mv /src/eblocker-lists/test_pom.xml /src/eblocker-lists/pom.xml
#truncate needed to remove a </dependency> string at the end of the pom.xml after awk 
RUN truncate -s -14 /src/eblocker-lists/pom.xml
RUN cd /src/eblocker-lists && mvn package -Pupdate-lists

# copy additional files

COPY configuration.properties /

COPY script_wrapper /

RUN chmod +x /script_wrapper

COPY start.sh /start.sh
RUN chmod +x /start.sh



# clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

ENTRYPOINT ["/start.sh"]

