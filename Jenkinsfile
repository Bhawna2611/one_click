pipeline {
    agent any
    
    // This block enables the "Build with Parameters" button in Jenkins
    parameters {
        choice(name: 'TF_ACTION', choices: ['apply', 'destroy'], description: 'Select the Terraform action to perform')
    }

    environment {
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
        // Using credentials directly to avoid insecure interpolation warnings
        AWS_CREDS = credentials('aws-keys')
        AWS_ACCESS_KEY_ID     = credentials('aws-keys').username 
        AWS_SECRET_ACCESS_KEY = credentials('aws-keys').password
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        // The "Choose Action" stage is removed because parameters are now set at the start

        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    // FIX: -input=false and -force-copy prevents the interactive prompt error
                    sh 'terraform init -input=false -migrate-state -force-copy'
                    
                    script {
                        // Access the parameter using the 'params' object
                        if (params.TF_ACTION == 'apply') {
                            sh 'terraform apply -auto-approve -input=false'
                        } else {
                            sh 'terraform destroy -auto-approve -input=false'
                        }
                    }
                }
            }
        }

        stage('Extract & Update Inventory') {
            // Run this only if the action was 'apply'
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                script {
                    dir("${env.TF_DIRECTORY}") {
                        env.BASTION_IP = sh(script: "terraform output -raw bastion_public_ip", returnStdout: true).trim()
                        env.PRIVATE_IP = sh(script: "terraform output -raw private_instance_ip", returnStdout: true).trim()
                    }
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "sed -i 's/BASTION_IP_PLACEHOLDER/${env.BASTION_IP}/g' inventory.ini"
                        sh "sed -i 's/PRIVATE_IP_PLACEHOLDER/${env.PRIVATE_IP}/g' inventory.ini"
                    }
                }
            }
        }

        stage('Ansible Lint') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                dir("${env.ANSIBLE_DIRECTORY}") {
                    sh 'ansible-lint -v playbook.yml || true' 
                }
            }
        }

        stage('Ansible Setup & Install Docker') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "cp ${SSH_KEY} /tmp/one_click.pem && chmod 400 /tmp/one_click.pem"
                        sh "ansible-playbook -i inventory.ini playbook.yml --private-key=/tmp/one_click.pem -u ubuntu"
                    }
                }
            }
        }

        stage('Deploy MySQL & Verify') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "ansible all -i inventory.ini -m copy -a 'src=../docker/ dest=/home/ubuntu/' --private-key=/tmp/one_click.pem -u ubuntu"
                        sh """
                            ansible all -i inventory.ini -m shell -a '
                                cd /home/ubuntu/docker && \
                                docker build -t custom-mysql . && \
                                docker run -d --name mysql-db -p 3306:3306 custom-mysql && \
                                docker ps
                            ' --become --private-key=/tmp/one_click.pem -u ubuntu
                        """
                    }
                }
            }
        }
    }

    post { 
        always { 
            // Cleanup the temporary SSH key
            sh 'rm -f /tmp/one_click.pem' 
        } 
    }
}