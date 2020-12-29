#!/bin/bash

JENKINS_DOCKER_IMAGE="${1}"
UPGRADE_PLUGINS="${2:-false}"

set -eu -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
CURL_OPTS=("--insecure" "--fail" "--location" "--silent" "--show-error" "--user" "butler:butler")
JENKINS_CONTAINER_NAME="${JENKINS_CONTAINER_NAME:-jenkins-plugins}"
PLUGINS_TXT_FILE="${CURRENT_DIR}/plugins.txt"

## Check for CLI requirements
for CLI in perl sed curl sort uniq docker
do
    command -v "${CLI}" >/dev/null 2>&1  || {
        echo "ERROR: Command Line ${CLI} not found but is required. Exiting."
        exit 1
    }
done

###### get_jenkins_plugins_list()
# Prints on the stdout the alphabetically order list of plugins installed on the provided Jenkins instance.
# The format of the stdout is one line per plugin, with the name and version on each line, separated by a colon (':')
#
# Arguments: none
function get_jenkins_plugins_list() {
    curl "${CURL_OPTS[@]}" "${1}/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
    | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' \
    | sed 's/ /:/' | sort | uniq
}

function retry() {
    counter=0
    max_retries="$1"
    shift
    waiting_time="$1"
    shift
    until [ "${counter}" -ge "${max_retries}" ]
    do
        if "$@"
        then
            break
        fi
        sleep "${waiting_time}"
        counter=$((counter+1))
    done
    if [ "${counter}" -ge "${max_retries}" ]
    then
        return 1
    fi
    return 0
}

function wait_for_jenkins_available() {
    retry 24 5 curl "${CURL_OPTS[@]}" --output /dev/null "${JENKINS_URL}/manage" || {
        echo "== ERROR: the Jenkins container ${JENKINS_CONTAINER_NAME} is not reachable after 2 minutes. Exiting."
        exit 1
    }
}

echo "== Starting a temporary Jenkins Controller's container..."
docker rm -v -f "${JENKINS_CONTAINER_NAME}" >/dev/null 2>&1 || true
docker run --detach \
    --name="${JENKINS_CONTAINER_NAME}" \
    --publish="8080:8080" \
    --env JAVA_OPTS="-XshowSettings:vm -Djenkins.install.runSetupWizard=false" \
    "${JENKINS_DOCKER_IMAGE}"

echo "== Checking if Jenkins container is up and healty..."
wait_for_jenkins_available
echo "== Jenkins container ${JENKINS_CONTAINER_NAME} is now reachable."

if [ "${UPGRADE_PLUGINS}" == "true" ]
then
    echo "== Upgrading plugins in the temporary Jenkins Controller..."
    curl -s -L http://updates.jenkins-ci.org/update-center.json \
        | sed '1d;$d' \
        | curl -s -X POST -H 'Accept: application/json' -d @- "${JENKINS_URL}"/updateCenter/byId/default/postBack
fi

echo "== Restarting Jenkins Controller..."
docker restart "${JENKINS_CONTAINER_NAME}"
wait_for_jenkins_available

echo "== Exporting the new plugins list..."
get_jenkins_plugins_list "${JENKINS_URL}" | tee "${PLUGINS_TXT_FILE}"
echo "== Updated plugin list is available at ${PLUGINS_TXT_FILE}. End of Script"
exit 0
