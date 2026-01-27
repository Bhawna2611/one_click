pipeline {
    agent any

    environment {
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
        
        LC_ALL = 'en_US.UTF-8'
        LANG   = 'en_US.UTF-8'
        // AWS Credentials binding
        AWS_CREDS = credentials('aws-keys')
        AWS_ACCESS_KEY_ID     = "${env.AWS_CREDS_USR}"
        AWS_SECRET_ACCESS_KEY = "${env.AWS_CREDS_PSW}"
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout Source') {
            steps {
                // Pull the source code from the repository
                checkout scm
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    // Initialize Terraform and provision the cloud resources
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Setup & Docker') {
            steps {
                // Bind the SSH private key (ID: my-server-ssh-key-v1) to a temporary file path
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        // Disable host key checking to prevent manual interaction and use the private key for connection
                        sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml --private-key=${SSH_KEY} -u ubuntu"
                    }
                }
            }
        }

        stage('Deploy MySQL on Docker') {
            steps {
                // Re-bind the SSH key for direct Ansible shell commands
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        // Run MySQL container on remote nodes using the shell module
                        sh "ANSIBLE_HOST_KEY_CHECKING=False ansible all -i inventory.ini -m shell -a 'docker run -d --name mysql-db -e MYSQL_ROOT_PASSWORD=password mysql:8.0' --private-key=${SSH_KEY} -u ubuntu"
                    }
                }
            }
        }

        stage('Verify Installation') {
            steps {
                // Final verification step using the SSH key
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    // Check if the MySQL container is running across all hosts in the inventory
                    sh "ANSIBLE_HOST_KEY_CHECKING=False ansible all -i inventory.ini -m shell -a 'docker ps | grep mysql' --private-key=${SSH_KEY} -u ubuntu"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        success {
            echo 'Infrastructure and MySQL deployed successfully!'
        }
        failure {
            echo 'Deployment failed. Please check the Jenkins console output for errors.'
        }
    }
}