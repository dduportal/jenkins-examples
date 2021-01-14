FROM jenkins/jenkins:2.263.2

## Install custom plugins
ADD ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file=/usr/share/jenkins/ref/plugins.txt
