pipeline {
  agent any
	environment {
		VAGRANT_INSECURE_SSH_KEY = credentials('vagrant_insecure_ssh_key')
	}
	stages{
	  stage('Show the Vagrant insecure SSH key') {
		  steps {
			  sh 'echo "SSH USER: ${VAGRANT_INSECURE_SSH_KEY_USR}"'
				sh 'cat ${VAGRANT_INSECURE_SSH_KEY}'
			}
		}
  }
}
