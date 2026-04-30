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
                        $password = aws ecr get-login-password --region $region
                        docker login --username AWS --password $password $ecrUrl
                        if ($LASTEXITCODE -ne 0) { exit 1 }
                        docker tag certverify-backend:latest "$ecrUrl/certverify-backend:latest"
                        docker tag certverify-frontend:latest "$ecrUrl/certverify-frontend:latest"
                        docker push "$ecrUrl/certverify-backend:latest"
                        if ($LASTEXITCODE -ne 0) { exit 1 }
                        docker push "$ecrUrl/certverify-frontend:latest"
                        if ($LASTEXITCODE -ne 0) { exit 1 }
                        Write-Host "Images pushed successfully!"
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    powershell '''
                        $EC2_IP = "13.212.14.169"
                        $ECR_URL = "794383793240.dkr.ecr.ap-southeast-1.amazonaws.com"
                        $KEY = $env:SSH_KEY

                        icacls $KEY /inheritance:r
                        icacls $KEY /remove "BUILTIN\\Users" 2>$null
                        icacls $KEY /remove "Everyone" 2>$null
                        icacls $KEY /grant "NT AUTHORITY\\SYSTEM:R"

                        $deployScript = "cd /home/ubuntu/certverify && aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin $ECR_URL && export COMPOSE_HTTP_TIMEOUT=300 && docker-compose down && docker-compose pull && docker-compose up -d && sleep 40 && docker exec certverify-backend python manage.py migrate --no-input && echo Done"

                        $deployScript | Out-File -FilePath "deploy.sh" -Encoding ASCII -NoNewline

                        scp -i $KEY -o StrictHostKeyChecking=no deploy.sh ubuntu@${EC2_IP}:/home/ubuntu/deploy.sh

                        ssh -i $KEY -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -o ServerAliveCountMax=10 ubuntu@$EC2_IP "bash /home/ubuntu/deploy.sh"

                        if ($LASTEXITCODE -ne 0) {
                            Write-Host "Deployment failed!"
                            exit 1
                        }
                        Write-Host "Deployed successfully!"
                    '''
                }
            }
        }
    }

    post {
        success { echo 'Pipeline completed! App live at http://13.212.14.169' }
        failure { echo 'Pipeline failed!' }
    }
}