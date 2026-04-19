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
                        Write-Host "Getting ECR token..."

                        # Save token to temp file
                        $tokenFile = "$env:TEMP\\ecr_token.txt"
                        aws ecr get-login-password --region ap-southeast-1 | Out-File -FilePath $tokenFile -Encoding ascii -NoNewline

                        Write-Host "Token saved. Logging into ECR..."

                        # Use temp file for docker login
                        Get-Content $tokenFile | docker login --username AWS --password-stdin $ecrUrl

                        if ($LASTEXITCODE -ne 0) {
                            Write-Host "Login failed!"
                            exit 1
                        }

                        # Clean up temp file
                        Remove-Item $tokenFile -Force

                        Write-Host "Login successful! Tagging images..."
                        docker tag certverify-backend:latest "$ecrUrl/certverify-backend:latest"
                        docker tag certverify-frontend:latest "$ecrUrl/certverify-frontend:latest"

                        Write-Host "Pushing backend..."
                        docker push "$ecrUrl/certverify-backend:latest"

                        Write-Host "Pushing frontend..."
                        docker push "$ecrUrl/certverify-frontend:latest"

                        Write-Host "Done! Images pushed to ECR successfully!"
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