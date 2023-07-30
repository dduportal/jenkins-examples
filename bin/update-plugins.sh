#!/usr/bin/env bash
# From https://github.com/jenkins-infra/docker-jenkins-weekly and https://github.com/jenkins-infra/docker-jenkins-lts
set -exu -o pipefail

TMP_DIR=$(mktemp -d)
new_plugin_file="${TMP_DIR}/plugins-new.txt"

{
  current_dir="$(cd "$(dirname "$0")" && pwd -P)"

  echo "Updating plugins..."

  # Fetches the latest plugin manager version via API, the asset has a version number in it unfortunately
  # So we can't just use the API to get the latest version without some parsing
  PM_CLI_DOWNLOAD_URL=$( \
    curl --silent --show-error --location 'https://api.github.com/repos/jenkinsci/plugin-installation-manager-tool/releases/latest' \
    | jq -r '.assets[] | select(.content_type=="application/x-java-archive").browser_download_url'\
  )

  TMP_DIR=$(mktemp -d)

  curl --silent --show-error --location --output "${TMP_DIR}/jenkins-plugin-manager.jar" \
    "${PM_CLI_DOWNLOAD_URL}"

  jenkins_dockerdir="${current_dir}/../docker-image"
  current_jenkins_version="$(grep 'ARG JENKINS_VERSION' "${jenkins_dockerdir}/Dockerfile" | cut -d'=' -f2)"

  curl --silent --show-error --location --output "${TMP_DIR}/jenkins.war" \
    "https://get.jenkins.io/war-stable/${current_jenkins_version}/jenkins.war"

  cd "${jenkins_dockerdir}" || exit 1

  java -jar "${TMP_DIR}/jenkins-plugin-manager.jar" -f "${jenkins_dockerdir}/plugins.txt" --available-updates --output txt --war "${TMP_DIR}/jenkins.war" > "${new_plugin_file}"

  echo "Updating plugins complete. New plugin set available in ${new_plugin_file}"
} >&2

cat "${new_plugin_file}"
