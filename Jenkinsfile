pipeline {
    agent any

    environment {
        TF_DIR = 'terraform'
        ANSIBLE_DIR = 'ansible'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/adityasingh345/devops-task-tracker'
            }
        }

        stage('Test App') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                    pytest
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-cred', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TF_DIR}") {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                            terraform output -raw instance_public_ip > ../ansible/ip.txt
                        '''
                    }
                }
            }
        }

        stage('Generate Inventory') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        IP=$(cat ip.txt)
                        echo "[app_servers]" > inventory.ini
                        echo "$IP ansible_user=ubuntu" >> inventory.ini
                    '''
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    dir("${ANSIBLE_DIR}") {
                        sh '''
                            ansible-playbook -i inventory.ini deploy.yml --ssh-common-args='-o StrictHostKeyChecking=no'
                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        IP=$(cat ip.txt)
                        sleep 10
                        curl -f http://$IP:5000/health
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded! App deployed and verified.'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs above.'
        }
    }
}