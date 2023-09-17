#!/usr/bin/env bash
# From https://github.com/jenkins-infra/docker-jenkins-weekly and https://github.com/jenkins-infra/docker-jenkins-lts
set -eu -o pipefail

TMP_DIR=$(mktemp -d)

new_plugin_filename=plugins-new.txt
new_plugin_file="${TMP_DIR}/${new_plugin_filename}"

{
  current_dir="$(cd "$(dirname "$0")" && pwd -P)"
  jenkins_dockerdir="${current_dir}/../docker-image"

  echo "Updating plugins..."

  # Retrieve current Jenkins Docker image full name
  jenkins_docker_image="$(grep FROM "${jenkins_dockerdir}"/Dockerfile | awk '{print $2}')"

  echo "-> Ensuring the Docker image '${jenkins_docker_image}' is present..."
  docker pull "${jenkins_docker_image}"
  echo "-> Image is present"

  container_name='jenkins_plugins_update'
  echo "-> Ensuring the Docker container '${container_name}' is started in background..."
  docker container rm --force "${container_name}" 2>&1 >/dev/null || true

  docker container run --detach --rm --entrypoint=sleep --name="${container_name}" "${jenkins_docker_image}" 300 # 5 min are enough otherwise there is a network issue
  # Wait for the container to be running
  sleep 2
  echo "-> Docker container '${container_name}' started in background"

  echo "-> Checking the last plugin available version in the Docker container '${container_name}'..."
  plugins_orig_path=/tmp/plugins.txt
  docker container cp "${jenkins_dockerdir}"/plugins.txt "${container_name}":"${plugins_orig_path}"

  docker container exec "${container_name}" jenkins-plugin-cli -f "${plugins_orig_path}" \
    --available-updates \
    --output txt \
    --war /usr/share/jenkins/jenkins.war \
    > "${new_plugin_file}"

  docker container rm --force "${container_name}" 2>&1 >/dev/null || true

  echo "-> Plugin list of last version retrieved in ${new_plugin_file}"
} >&2

cat "${new_plugin_file}"
