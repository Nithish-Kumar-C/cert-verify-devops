pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '794383793240'
        AWS_REGION = 'ap-southeast-1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Nithish-Kumar-C/cert-verify-devops.git'
            }
        }
        
        stage('Build Backend') {
            steps {
                bat 'docker build -t certverify-backend ./backend'
            }
        }
        
        stage('Build Frontend') {
            steps {
                bat 'docker build -t certverify-frontend ./frontend'
            }
        }
        
        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'aws-credentials', region: 'ap-southeast-1') {
                    bat """
                        aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
                        docker tag certverify-backend:latest %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/certverify-backend:latest
                        docker tag certverify-frontend:latest %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/certverify-frontend:latest
                        docker push %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/certverify-backend:latest
                        docker push %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/certverify-frontend:latest
                    """
                }
            }
        }
    }
    
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed!' }
    }
}