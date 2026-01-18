# infrastructure/Dockerfile
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install basic dependencies and build tools
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    unzip \
    software-properties-common \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Snyk CLI (Required by your action.yaml)
RUN curl --compressed https://static.snyk.io/cli/latest/snyk-linux -o /usr/local/bin/snyk \
    && chmod +x /usr/local/bin/snyk

# 3. Install GitHub Actions Runner
# (Check https://github.com/actions/runner/releases for the latest version)
ARG RUNNER_VERSION="2.330.0"
WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# 4. Install dependencies for the runner
RUN ./bin/installdependencies.sh

# 5. Create a non-root user (GitHub Runner should not run as root)
RUN useradd -m runner && chown -R runner:runner /actions-runner
USER runner

# 6. Copy entrypoint script
COPY --chown=runner:runner entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh

ENTRYPOINT ["/actions-runner/entrypoint.sh"]
