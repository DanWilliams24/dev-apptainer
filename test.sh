#!/bin/bash
set -e

source "$(dirname "$0")/load_config.sh"

echo "PROJECT_ROOT is $PROJECT_ROOT"
echo "Using container image: $CONTAINER_IMAGE"
