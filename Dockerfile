FROM ubuntu:22.04

ARG RUNNER_VERSION="2.317.0"
ARG DEBIAN_FRONTEND=noninteractive

# Update and upgrade the system
RUN apt update -y && apt upgrade -y

# Add a user named docker
RUN useradd -m docker

# Install necessary packages
RUN apt install -y --no-install-recommends \
    curl build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip jq

COPY --chmod=+x install-docker.sh /install-docker.sh

RUN sh /install-docker.sh

RUN apt-get -yqq install ssh
# Set up the actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner

RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Change ownership to docker user and install dependencies
RUN chown -R docker /home/docker
RUN sh /home/docker/actions-runner/bin/installdependencies.sh

# Copy the start script and make it executable
COPY --chmod=+x start.sh /start.sh

# Switch to docker user
USER docker

# Define the entrypoint
ENTRYPOINT ["/start.sh"]
