#!/bin/bash
# infrastructure/entrypoint.sh

set -e

# Validate required environment variables
if [ -z "$GITHUB_URL" ]; then echo "Error: GITHUB_URL is not set"; exit 1; fi
if [ -z "$REGISTRATION_TOKEN" ]; then echo "Error: REGISTRATION_TOKEN is not set"; exit 1; fi
if [ -z "$RUNNER_NAME" ]; then echo "Error: RUNNER_NAME is not set"; exit 1; fi

echo "Configuring GitHub Actions Runner..."

# --ephemeral: The runner will unconfigure itself after processing one job
# --unattended: Run without user interaction
# --replace: Replace any existing runner with the same name (useful for retries)
./config.sh \
    --url "$GITHUB_URL" \
    --token "$REGISTRATION_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "ecs-runner,java,snyk" \
    --unattended \
    --ephemeral \
    --replace

echo "Starting Runner..."

# The runner will listen for a job, run it, and then exit.
./run.sh
