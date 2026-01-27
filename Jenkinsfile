pipeline {
    agent any

    environment {
        TF_DIRECTORY      = 'terraform'
        ANSIBLE_DIRECTORY   = 'ansible'
        
        // Mapping Jenkins credentials to variables
        // Make sure the IDs 'aws-keys' and 'my-server-ssh-key' match exactly in Jenkins
        AWS_ACCESS_KEY_ID     = credentials('aws-keys-id') // Replace with your actual Credential ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-keys-secret') // Replace with your actual Credential ID
        AWS_DEFAULT_REGION    = 'us-east-1' 
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    // Terraform will automatically pick up AWS_ACCESS_KEY_ID from environment
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Setup & Docker') {
            steps {
                // withCredentials is used here to handle the SSH Private Key for Ansible
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        // We pass the SSH key to Ansible using --private-key
                        sh "ansible-playbook -i inventory.ini playbook.yml --private-key=${SSH_KEY}"
                    }
                }
            }
        }

        stage('Deploy MySQL on Docker') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "ansible all -i inventory.ini -m shell -a 'docker run -d --name mysql-db mysql:8.0' --private-key=${SSH_KEY}"
                    }
                }
            }
        }
        
        stage('Verify Installation') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "ansible all -i inventory.ini -m shell -a 'docker ps | grep mysql' --private-key=${SSH_KEY}"
                    }
                }
            }
        }
    }

    post {
        always { echo 'Pipeline execution finished.' }
        success { echo 'Infrastructure and MySQL deployed successfully!' }
        failure { echo 'Deployment failed. Check Jenkins logs.' }
    }
}