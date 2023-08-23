pipeline{
    agent any   

    environment{
        IMAGE_TAG = 'latest'
        ECR_REPO = 'your-ecr-repository-url'
        ap-northeast-2
    }
    stages{
        stage('Clone'){
            steps{
                git branch: 'feature/deploy', 
                url: 'https://github.com/FISA-on-Top/Nginx.git'
            }
        }
        stage('Build Docker Image'){
            steps{
                script{
                    sh 'docker build --no-cache -t nginx-react:${IMAGE_TAG} .'
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    echo "aws cli 설치"
                    sh '''
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip awscliv2.zip
                        sudo ./aws/install
                    '''
                    // // ECR에 로그인합니다.
                    // sh 'aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 038331013212.dkr.ecr.ap-northeast-2.amazonaws.com'
                    
                    // // 이미지를 ECR에 푸시합니다.
                    // sh 'docker tag jenkins:latest 038331013212.dkr.ecr.ap-northeast-2.amazonaws.com/top_hub:latest'
                    // sh 'docker push 038331013212.dkr.ecr.ap-northeast-2.amazonaws.com/top_hub'
                }
            }
        }
    }    
}