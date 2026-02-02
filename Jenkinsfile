pipeline {
    agent any
    environment {
        TF_DIRECTORY = 'terraform'
        ANSIBLE_DIRECTORY = 'ansible'
        AWS_CREDS = credentials('aws-keys')
        AWS_ACCESS_KEY_ID     = "${env.AWS_CREDS_USR}"
        AWS_SECRET_ACCESS_KEY = "${env.AWS_CREDS_PSW}"
        AWS_DEFAULT_REGION    = 'us-east-1'
    }
    stages {
        stage('Checkout Source') {
            steps { checkout scm }
        }
        stage('Choose Action') {
            steps {
                script {
                    def action = input message: 'Choose Terraform action', parameters: [choice(name: 'ACTION', choices: "apply\ndestroy", description: 'Choose apply or destroy')]
                    env.TF_ACTION = action
                }
            }
        }
        stage('Terraform Infrastructure') {
            steps {
                dir("${env.TF_DIRECTORY}") {
                    sh 'terraform init'
                    script {
                        if (env.TF_ACTION == 'apply') {
                            sh 'terraform apply -auto-approve'
                        } else {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }
        stage('Extract & Update Inventory') {
            when { expression { env.TF_ACTION == 'apply' } }
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
            when { expression { env.TF_ACTION == 'apply' } }
            steps {
                dir("${env.ANSIBLE_DIRECTORY}") {
                    sh 'ansible-lint -v playbook.yml'
                }
            }
        }
        stage('Ansible Setup & Install Docker') {
            when { expression { env.TF_ACTION == 'apply' } }
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
            when { expression { env.TF_ACTION == 'apply' } }
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
    post { always { sh 'rm -f /tmp/one_click.pem' } }
}