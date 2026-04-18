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
                        $env:AWS_DEFAULT_REGION = "ap-southeast-1"
                        $accountId = $env:AWS_ACCOUNT_ID
                        $region = "ap-southeast-1"
                        $ecrUrl = "$accountId.dkr.ecr.$region.amazonaws.com"
                        
                        Write-Host "ECR URL: $ecrUrl"
                        Write-Host "Getting ECR password..."
                        
                        $password = (aws ecr get-login-password --region ap-southeast-1)
                        
                        Write-Host "Logging into ECR..."
                        Write-Output $password | docker login --username AWS --password-stdin $ecrUrl
                        
                        if ($LASTEXITCODE -ne 0) { 
                            Write-Host "Login failed!"
                            exit 1 
                        }
                        
                        Write-Host "Tagging and pushing images..."
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