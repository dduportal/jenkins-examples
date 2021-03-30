FROM jenkins/jenkins:2.277.1-alpine

## Install custom plugins
COPY --chown=jenkins:jenkins ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file=/usr/share/jenkins/ref/plugins.txt
