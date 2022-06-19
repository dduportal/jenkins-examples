FROM jenkins/jenkins:lts-jdk11

## Disable the startup wizard
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

## Install custom plugins
# To update plugins: docker run --rm -v "$(pwd):$(pwd):ro" --entrypoint=jenkins-plugin-cli jenkins/jenkins:2.332-jdk11 --available-updates --war /usr/share/jenkins/jenkins.war --output txt --plugin-file "$(pwd)"/plugins.txt
COPY --chown=jenkins:jenkins ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file=/usr/share/jenkins/ref/plugins.txt
