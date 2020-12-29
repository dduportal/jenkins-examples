FROM jenkins/jenkins:2.263.1

## Install custom plugins
ADD ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file=/usr/share/jenkins/ref/plugins.txt
