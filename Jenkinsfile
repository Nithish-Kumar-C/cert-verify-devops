pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Nithish-Kumar-C/cert-verify-devops.git'
            }
        }
        
        stage('Build Backend') {
            steps {
                powershell 'docker build -t certverify-backend ./backend'
            }
        }
        
        stage('Build Frontend') {
            steps {
                powershell 'docker build -t certverify-frontend ./frontend'
            }
        }
        
        stage('Push to ECR') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ],
                    string(credentialsId: 'aws-account-id', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    powershell '''
                        $region = "ap-southeast-1"
                        $accountId = $env:AWS_ACCOUNT_ID
                        $ecrUrl = "$accountId.dkr.ecr.$region.amazonaws.com"
                        
                        # Set credentials explicitly for aws cli
                        $env:AWS_ACCESS_KEY_ID = $env:AWS_ACCESS_KEY_ID
                        $env:AWS_SECRET_ACCESS_KEY = $env:AWS_SECRET_ACCESS_KEY
                        $env:AWS_DEFAULT_REGION = $region
                        
                        Write-Host "Testing AWS credentials..."
                        aws sts get-caller-identity
                        
                        Write-Host "Getting ECR token..."
                        $token = aws ecr get-login-password --region $region
                        
                        Write-Host "Token length: $($token.Length)"
                        Write-Host "Logging into ECR: $ecrUrl"
                        
                        $token | docker login --username AWS --password-stdin $ecrUrl
                        
                        if ($LASTEXITCODE -ne 0) { exit 1 }
                        
                        docker tag certverify-backend:latest "$ecrUrl/certverify-backend:latest"
                        docker tag certverify-frontend:latest "$ecrUrl/certverify-frontend:latest"
                        docker push "$ecrUrl/certverify-backend:latest"
                        docker push "$ecrUrl/certverify-frontend:latest"
                        Write-Host "Done!"
                    '''
                }
            }
        }
    }
    
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed!' }
    }
}