#!/bin/bash

set -eu -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

# Only the first FROM instruction, and only the 2nd column (there could be suffix "AS <blah>")
JENKINS_IMAGE="$(grep FROM "${CURRENT_DIR}"/Dockerfile | head -n1 | awk '{print $2}')"
NEW_PLUGINS_FILE="$(mktemp)"

docker run --rm --interactive --tty \
  --volume "${CURRENT_DIR}/plugins.txt:/usr/share/jenkins/ref/plugins.txt:ro" \
  "${JENKINS_IMAGE}" bash -c \
  "stty -onlcr && jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt --available-updates --output txt" \
  > "${NEW_PLUGINS_FILE}"

mv "${NEW_PLUGINS_FILE}" "${CURRENT_DIR}"/plugins.txt
