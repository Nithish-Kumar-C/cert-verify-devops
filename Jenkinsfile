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

                        Write-Host "ECR URL: $ecrUrl"

                        # Get token as string
                        $password = aws ecr get-login-password --region $region
                        Write-Host "Token length: $($password.Length)"

                        # Login using --password flag directly (no pipe)
                        docker login --username AWS --password $password $ecrUrl

                        if ($LASTEXITCODE -ne 0) {
                            Write-Host "Login failed!"
                            exit 1
                        }

                        Write-Host "Login successful!"

                        docker tag certverify-backend:latest "$ecrUrl/certverify-backend:latest"
                        docker tag certverify-frontend:latest "$ecrUrl/certverify-frontend:latest"

                        docker push "$ecrUrl/certverify-backend:latest"
                        if ($LASTEXITCODE -ne 0) { exit 1 }

                        docker push "$ecrUrl/certverify-frontend:latest"
                        if ($LASTEXITCODE -ne 0) { exit 1 }

                        Write-Host "Done! Images pushed successfully!"
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