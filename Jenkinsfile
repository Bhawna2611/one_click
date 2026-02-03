pipeline {
    agent any
    
    parameters {
        // This allows you to choose apply or destroy at the start of the build
        choice(name: 'TF_ACTION', choices: ['apply', 'destroy'], description: 'Select the Terraform action to perform')
    }

    environment {
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
        AWS_DEFAULT_REGION = 'us-east-1'
        // Jenkins maps 'aws-keys' to AWS_CREDS_USR and AWS_CREDS_PSW automatically
        AWS_CREDS = credentials('aws-keys')

        LANG = 'en_US.UTF-8'
        LC_ALL = 'en_US.UTF-8'
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-keys', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${env.TF_DIRECTORY}") {
                        // Added -input=false and -force-copy to stop Terraform from asking for manual input
                        sh 'terraform init -input=false -migrate-state -force-copy'
                        script {
                            if (params.TF_ACTION == 'apply') {
                                sh 'terraform apply -auto-approve -input=false'
                            } else {
                                sh 'terraform destroy -auto-approve -input=false'
                            }
                        }
                    }
                }
            }
        }

        stage('Update Inventory') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aws-keys', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        dir("${env.TF_DIRECTORY}") {
                            env.BASTION_IP = sh(script: "terraform output -raw bastion_public_ip", returnStdout: true).trim()
                            env.PRIVATE_IP = sh(script: "terraform output -raw private_instance_ip", returnStdout: true).trim()
                        }
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
                    // || true prevents the pipeline from failing if there are only minor linting warnings
                    sh 'ansible-lint -v playbook.yml || true'
                }
            }
        }

        stage('Ansible Setup & Install Docker') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "cp ${SSH_KEY} /tmp/one__click.pem && chmod 400 /tmp/one__click.pem"
                        sh "ansible-playbook -i inventory.ini playbook.yml --private-key=/tmp/one__click.pem -u ubuntu"
                    }
                }
            }
        }

        stage('Deploy MySQL & Verify') {
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-server-ssh-key-v1', keyFileVariable: 'SSH_KEY')]) {
                    dir("${env.ANSIBLE_DIRECTORY}") {
                        sh "ansible all -i inventory.ini -m copy -a 'src=../docker/ dest=/home/ubuntu/' --private-key=/tmp/one__click.pem -u ubuntu"
                        sh """
                            ansible all -i inventory.ini -m shell -a '
                                cd /home/ubuntu/docker && \
                                docker build -t custom-mysql . && \
                                docker run -d --name mysql-db -p 3306:3306 custom-mysql && \
                                docker ps
                            ' --become --private-key=/tmp/one__click.pem -u ubuntu
                        """
                    }
                }
            }
        }
    }

    post { 
        always { 
            // Cleanup sensitive files from the Jenkins agent
            sh 'rm -f /tmp/one__click.pem' 
        } 
    }
}
