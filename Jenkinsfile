pipeline {
    agent any

    environment {
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
        
        // Ensure consistent encoding across the pipeline
        LC_ALL = 'en_US.UTF-8'
        LANG   = 'en_US.UTF-8'
        
        // AWS Credentials binding for Terraform provider
        AWS_CREDS = credentials('aws-keys')
        AWS_ACCESS_KEY_ID     = "${env.AWS_CREDS_USR}"
        AWS_SECRET_ACCESS_KEY = "${env.AWS_CREDS_PSW}"
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout Source') {
            steps {
                // Pull latest code from GitHub
                checkout scm
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    // Initialize and apply infrastructure changes via Terraform
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
                            # Align Jenkins secret key with the path defined in inventory.ini
                            cp ${SSH_KEY} /tmp/one_click.pem
                            chmod 400 /tmp/one_click.pem
                            
                            # Run base playbook to configure the remote server (e.g., Install Docker)
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
                            # Preparation: Ensure the SSH key is available for the tunnel
                            cp ${SSH_KEY} /tmp/one_click.pem
                            chmod 400 /tmp/one_click.pem

                            # 1. Transfer Docker build context (Dockerfile) to the private web server
                            ANSIBLE_HOST_KEY_CHECKING=False ansible web -i inventory.ini -m copy -a 'src=../docker/ dest=/home/ubuntu/mysql_project' --private-key=/tmp/one_click.pem -u ubuntu

                            # 2. Build the Custom Image and Deploy the Container
                            ANSIBLE_HOST_KEY_CHECKING=False ansible web -i inventory.ini -m shell -a '
                                cd /home/ubuntu/mysql_project && \
                                
                                # A. Build the image from your local Dockerfile
                                echo "Building Docker image..." && \
                                docker build -t bhawna-mysql:latest . && \
                                
                                # B. Remove any existing container to avoid conflicts
                                echo "Removing old container if exists..." && \
                                docker stop mysql-db || true && \
                                docker rm mysql-db || true && \
                                
                                # C. Start a new container from the newly built image
                                echo "Running new container..." && \
                                docker run -d --name mysql-db -p 3306:3306 bhawna-mysql:latest
                            ' --become --private-key=/tmp/one_click.pem -u ubuntu
                        """
                    }
                }
            }
        }

        stage('Verify Installation') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        # Maintenance: Refresh key for verification tasks
                        cp ${SSH_KEY} /tmp/one_click.pem
                        chmod 400 /tmp/one_click.pem
                        
                        # Check if the mysql-db container is active and running
                        ANSIBLE_HOST_KEY_CHECKING=False ansible web -i inventory.ini -m shell -a 'docker ps | grep mysql' --become --private-key=/tmp/one_click.pem -u ubuntu
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
            // Security: Remove the sensitive private key from /tmp after run
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