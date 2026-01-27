pipeline {
    agent any

    environment {
        // Define directory paths based on your repository structure
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
    }

    stages {
        stage('Checkout Source') {
            steps {
                // Pull the latest code from the Git repository
                checkout scm
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    // Initialize Terraform and provision the infrastructure
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Setup & Docker') {
            steps {
                dir("${env.ANSIBLE_DIRECTORY}") {
                    // Execute Ansible playbook to install Docker on the provisioned nodes
                    // Ensure inventory.ini contains the target host IPs
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }

        stage('Deploy MySQL on Docker') {
            steps {
                dir("${env.ANSIBLE_DIRECTORY}") {
                    // Run the MySQL container using Docker commands via Ansible shell module
                    // This uses the 'Deep Clean' logic we discussed earlier for GPG keys
                    sh 'ansible all -i inventory.ini -m shell -a "docker run -d --name mysql-db mysql:8.0"'
                }
            }
        }

        stage('Verify Installation') {
            steps {
                // Final check to ensure the MySQL container is up and running
                sh 'ansible all -i inventory.ini -m shell -a "docker ps | grep mysql"'
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
