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
        
        // Ansible settings
        ANSIBLE_HOST_KEY_CHECKING = 'False'
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
        
        stage('Extract Terraform Outputs') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    script {
                        env.BASTION_IP = sh(script: 'terraform output -raw bastion_public_ip', returnStdout: true).trim()
                        env.PRIVATE_IP = sh(script: 'terraform output -raw private_instance_ip', returnStdout: true).trim()
                        
                        echo "Bastion IP: ${env.BASTION_IP}"
                        echo "Private Instance IP: ${env.PRIVATE_IP}"
                    }
                }
            }
        }
        
        stage('Setup SSH Key & Update Inventory') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh """
                            # Setup SSH key
                            cp ${SSH_KEY} /tmp/one__click.pem
                            chmod 400 /tmp/one__click.pem
                            
                            # Backup original inventory
                            cp inventory.ini inventory.ini.bak
                            
                            # Update inventory with actual IPs
                            sed -i 's/BASTION_IP_PLACEHOLDER/${BASTION_IP}/g' inventory.ini
                            sed -i 's/PRIVATE_IP_PLACEHOLDER/${PRIVATE_IP}/g' inventory.ini
                            
                            echo "Updated inventory.ini:"
                            cat inventory.ini
                        """
                    }
                }
            }
        }
        
        stage('Install Ansible Role from Git') {
            steps {
                dir("${env.ANSIBLE_DIRECTORY}") {
                    sh """
                        # Install docker role from Git repository
                        ansible-galaxy install -r requirements.yml --force
                    """
                }
            }
        }
        
        stage('Test SSH Connectivity') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        # Test bastion connection
                        echo "Testing connection to Bastion..."
                        ssh -i /tmp/one__click.pem -o StrictHostKeyChecking=no -o ConnectTimeout=10 ubuntu@${BASTION_IP} "echo 'Bastion connection successful'"
                        
                        # Test private instance connection via bastion
                        echo "Testing connection to Private Instance via Bastion..."
                        ssh -i /tmp/one__click.pem -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
                            -o ProxyCommand="ssh -i /tmp/one__click.pem -W %h:%p -q ubuntu@${BASTION_IP}" \
                            ubuntu@${PRIVATE_IP} "echo 'Private instance connection successful'"
                    """
                }
            }
        }
        
        stage('Ansible Setup & Install Docker') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh """
                            # Run playbook to install Docker
                            ansible-playbook -i inventory.ini playbook.yml --private-key=/tmp/one__click.pem -v
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
                            # Copy Dockerfile/app files to remote server via bastion
                            ansible private_instances -i inventory.ini -m copy \
                                -a 'src=../docker/ dest=/home/ubuntu/' \
                                --private-key=/tmp/one__click.pem
                            
                            # Build and Run MySQL container
                            ansible private_instances -i inventory.ini -m shell \
                                -a 'cd /home/ubuntu/docker && \
                                    docker build -t custom-mysql . && \
                                    docker stop mysql-db || true && \
                                    docker rm mysql-db || true && \
                                    docker run -d --name mysql-db -p 3306:3306 custom-mysql' \
                                --become --private-key=/tmp/one__click.pem
                        """
                    }
                }
            }
        }
        
        stage('Verify Installation') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh """
                            # Verify Docker is running
                            ansible private_instances -i inventory.ini -m shell \
                                -a 'docker --version' \
                                --private-key=/tmp/one__click.pem
                            
                            # Verify MySQL container is running
                            ansible private_instances -i inventory.ini -m shell \
                                -a 'docker ps | grep mysql' \
                                --become --private-key=/tmp/one__click.pem
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution finished.'
            // Cleanup sensitive key file from /tmp
            sh 'rm -f /tmp/one__click.pem'
            
            // Restore original inventory file
            dir("${env.ANSIBLE_DIRECTORY}") {
                sh 'test -f inventory.ini.bak && mv inventory.ini.bak inventory.ini || true'
            }
        }
        success {
            echo '✅ Infrastructure and MySQL deployed successfully!'
            echo "Bastion Host: ${env.BASTION_IP}"
            echo "Private Instance: ${env.PRIVATE_IP}"
        }
        failure {
            echo '❌ Deployment failed. Please check the Jenkins console output for errors.'
        }
    }
}
