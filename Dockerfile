FROM cypress/browsers:chrome69

ENV SONAR_SCANNER_VERSION 3.2.0.1227

# Install required dependencies for docker
RUN set -ex; \
    apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    locales \
    git

# Install Docker from the Docker repositories
RUN curl -sSL https://get.docker.com/ | sh

# Install the docker wrapper script
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
RUN docker-compose --version

# Update git to 2.11.0
RUN echo "deb http://deb.debian.org/debian jessie-backports main" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y -t jessie-backports install git

# Install Java 8 (needed for SonarQube)
RUN apt-get -y install software-properties-common
RUN add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get -y install oracle-java8-installer

# Install SonarQube
ADD https://bintray.com/sonarsource/SonarQube/download_file?file_path=org%2Fsonarsource%2Fscanner%2Fcli%2Fsonar-scanner-cli%2F${SONAR_SCANNER_VERSION}%2Fsonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip /tmp/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip
RUN unzip /tmp/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip -d /usr/lib && \
    ln -s /usr/lib/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /usr/bin/sonar-scanner
    
# Install Swagger Codegen
RUN wget -qO- https://api.github.com/repos/swagger-api/swagger-codegen/tarball/master | tar zxv -C /swagger-api \
    && mv /swagger-api/swagger-api-swagger-codegen* /swagger-api/swagger-codegen/ \
    && ln -s /swagger-api/swagger-codegen/modules/swagger-codegen/src/test/resources/2_0/ /swagger-api/yaml

# Define additional metadata for the image
VOLUME /var/lib/docker
CMD ["wrapdocker"]
