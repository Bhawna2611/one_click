pipeline {
    agent any

    environment {
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
        
        // Fix for Locale/Encoding error
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
                checkout scm
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Setup & Docker') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh """
                            # Copying Jenkins secret key to the path expected by inventory.ini
                            cp ${SSH_KEY} /tmp/one_click.pem
                            chmod 400 /tmp/one_click.pem
                            
                            # Running the playbook
                            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml --private-key=/tmp/one_click.pem -u ubuntu
                        """
                    }
                }
            }
        }

        stage('Deploy MySQL on Docker') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh """
                            # Ensure key exists and has correct permissions
                            cp ${SSH_KEY} /tmp/one_click.pem
                            chmod 400 /tmp/one_click.pem

                            # 1. Copy Dockerfile/app files to remote server
                            ANSIBLE_HOST_KEY_CHECKING=False ansible web -i inventory.ini -m copy -a 'src=../docker/ dest=/home/ubuntu/' --private-key=/tmp/one_click.pem -u ubuntu

                            # 2. Build and Run MySQL
                            ANSIBLE_HOST_KEY_CHECKING=False ansible web -i inventory.ini -m shell -a '
                            cd /home/ubuntu/docker && \
                            docker build -t custom-mysql . && \
                            docker stop mysql-db || true && \
                            docker rm mysql-db || true && \
                            docker run -d --name mysql-db -p 3306:3306 custom-mysql' \
                            --become --private-key=/tmp/one_click.pem -u ubuntu
                        """
                    }
                }
            }
        }

        stage('Verify Installation') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        cp ${SSH_KEY} /tmp/one_click.pem
                        chmod 400 /tmp/one_click.pem
                        
                        ANSIBLE_HOST_KEY_CHECKING=False ansible web -i inventory.ini -m shell -a 'docker ps | grep mysql' --become --private-key=/tmp/one_click.pem -u ubuntu
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
            // Cleanup sensitive key file from /tmp
            sh 'rm -f /tmp/one_click.pem'
        }
        success {
            echo 'Infrastructure and MySQL deployed successfully!'
        }
        failure {
            echo 'Deployment failed. Please check the Jenkins console output for errors.'
        }
    }
}