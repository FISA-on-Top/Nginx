pipeline{
    agent any   

    environment{
        TIME_ZONE = 'Asia/Seoul'

        //REPOSITORY_CREDENTIAL_ID = 'gitlab-jenkins-key'
        REPOSITORY_URL = 'https://github.com/FISA-on-Top/Nginx.git'
        TARGET_BRANCH = 'feature/deploy' 

        CONTAINER_NAME = 'nginx-react'

        AWS_CREDENTIAL_NAME = 'ECR-access'
        ECR_PATH = '038331013212.dkr.ecr.ap-northeast-2.amazonaws.com'
        IMAGE_NAME = '038331013212.dkr.ecr.ap-northeast-2.amazonaws.com/nginx'
        REGION = 'ap-northeast-2'
    }
    stages{
        stage('init') {
            steps {
                echo 'init stage'
                deleteDir()
            }
            post {
                success {
                    echo 'success init in pipeline'
                }
                failure {
                    error 'fail init in pipeline'
                }
            }
        }    
        stage('Clone'){
            steps{
                git branch: "$TARGET_BRANCH", 
                url: "$REPOSITORY_URL"
                sh "ls -al"
            }
            post{
                success {
                    echo 'success clone project'
                }
                failure {
                    error 'fail clone project' // exit pipeline
                }     
            }
        }
        stage('Build Docker Image'){
            steps{
                script{
                    sh '''
                    docker build --no-cache -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:latest
                    '''
                }
            }
            post{
                success {
                    echo 'success dockerizing project'
                }
                failure {
                    error 'fail dockerizing project' // exit pipeline
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    // cleanup current user docker credentials
                    sh 'rm -f ~/.dockercfg ~/.docker/config.json || true'

                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_NAME}") {
                      docker.image("${IMAGE_NAME}:${BUILD_NUMBER}").push()
                      docker.image("${IMAGE_NAME}:latest").push()
                    }
                }
            }
        }
        post {
            success {
                echo 'success upload image'
            }
            failure {
                error 'fail upload image' // exit pipeline
            }
        }
    }    
}