## Weekly version
FROM jenkins/jenkins:2.296-jdk11

## Install custom plugins
COPY --chown=jenkins:jenkins ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file=/usr/share/jenkins/ref/plugins.txt
