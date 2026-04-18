pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = 'YOUR_ACCOUNT_ID'
        AWS_REGION = 'ap-southeast-1'
        ECR_BACKEND = "${794383793240}.dkr.ecr.${ap-southeast-1}.amazonaws.com/certverify-backend"
        ECR_FRONTEND = "${794383793240}.dkr.ecr.${ap-southeast-1}.amazonaws.com/certverify-frontend"
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
                        docker tag certverify-backend:latest %ECR_BACKEND%:latest
                        docker tag certverify-frontend:latest %ECR_FRONTEND%:latest
                        docker push %ECR_BACKEND%:latest
                        docker push %ECR_FRONTEND%:latest
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}