FROM jenkins/jenkins:2.440.1-jdk17

## Disable the startup wizard
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

COPY --chown=jenkins:jenkins ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file=/usr/share/jenkins/ref/plugins.txt
