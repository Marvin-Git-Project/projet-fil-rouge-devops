// Pipeline CI/CD - Projet Fil Rouge IC GROUP
// Build, test, push, provisionnement Terraform et deploiement Ansible

pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = "marvindocker28/ic-webapp"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lire la version') {
            steps {
                script {
                    env.APP_VERSION = sh(
                        script: "awk '/version/ {print \$2}' releases.txt",
                        returnStdout: true
                    ).trim()
                    echo "Version detectee : ${env.APP_VERSION}"
                }
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${env.APP_VERSION} ."
            }
        }

        stage('Test') {
            steps {
                sh """
                    docker rm -f test-pipeline || true
                    docker run -d --name test-pipeline ${IMAGE_NAME}:${env.APP_VERSION}
                    sleep 5
                    CONTAINER_IP=\$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test-pipeline)
                    curl -f http://\$CONTAINER_IP:8080 || exit 1
                    docker stop test-pipeline
                    docker rm test-pipeline
                """
            }
        }

        stage('Push Docker Hub') {
            steps {
                sh """
                    echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${IMAGE_NAME}:${env.APP_VERSION}
                """
            }
        }

        stage('Terraform') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sshagent(credentials: ['ssh-ansible-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@52.47.143.52 '
                                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                                cd ~/terraform
                                terraform init -input=false
                                terraform apply -auto-approve -input=false
                            '
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sshagent(credentials: ['ssh-ansible-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@52.47.143.52 '
                                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                                cd ~/terraform
                                IP_APP=\$(terraform output -raw ip_app_pgadmin)
                                IP_ODOO=\$(terraform output -raw ip_odoo)
                                cd ~/ansible-icgroup
                                cat > hosts << INVENTORY
[app_pgadmin]
serveur2 ansible_host=\$IP_APP ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/projet-fil-rouge-key.pem

[odoo]
serveur3 ansible_host=\$IP_ODOO ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/projet-fil-rouge-key.pem
INVENTORY
                                sleep 60
                                ansible-playbook -i hosts deploy.yml
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline termine avec succes - version ${env.APP_VERSION}"
        }
        failure {
            echo "Le pipeline a echoue"
        }
    }
}
