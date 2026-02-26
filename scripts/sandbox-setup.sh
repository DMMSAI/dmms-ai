#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="dryads-ai-sandbox:bookworm-slim"

docker build -t "${IMAGE_NAME}" -f Dockerfile.sandbox .
echo "Built ${IMAGE_NAME}"
