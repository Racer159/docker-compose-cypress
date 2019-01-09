FROM cypress/browsers:chrome69

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

# Define additional metadata for the image
VOLUME /var/lib/docker
CMD ["wrapdocker"]