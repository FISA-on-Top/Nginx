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
        IMAGE_NAME = 'nginx'
        REGION = 'ap-northeast-2'

        WEBSERVER_USERNAME = 'ubuntu'
        WEBSERVER_IP = '43.201.20.90' 
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
                    docker build -t ${IMAGE_NAME}:latest .
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_PATH/$IMAGE_NAME:$BUILD_NUMBER
                    docker tag $IMAGE_NAME:latest $ECR_PATH/$IMAGE_NAME:latest
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
            post {
                success {
                    echo 'success upload image'
                }
                failure {
                    error 'fail upload image' // exit pipeline
                }
            }
        }
        stage ('Pull to Web server from ECR') {

            steps{
                sshagent(credentials:[]'devfront-server']){
                    script{
                        // Login to ECR and pull the Docker image
                        def login = sh(script: "aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 038331013212.dkr.ecr.ap-northeast-2.amazonaws.com", returnStdout: true).trim()
                        echo "Logged in to AWS ECR with ${login}"

                        // SSH into the web server
                        sh '''
                        ssh -o StrictHostKeyChecking=yes ${WEBSERVER_USERNAME}@${WEBSERVER_IP} << EOF
                            # Pull image from ECR to web server
                            docker pull ${ECR_PATH}/${IMAGE_NAME}:latest
                            
                            # Remove the existing 'nginx' container, if it exists
                            if docker ps -a | grep ${CONTAINER_NAME}; then
                                docker rm -f ${CONTAINER_NAME}
                            fi

                            # Run a new Docker container using the image from ECR
                            docker run -d \
                            -p 80:80\
                            -v ~/nginx/build:/usr/share/nginx/html \
                            --name ${CONTAINER_NAME} ${ECR_PATH}/${IMAGE_NAME}:latest
                        EOF
                        '''
                    }
                }
            }
        }
        
        stage ('Deploy to Web server from ECR') {
            agent{
                sshagent(['6418520a-09b4-481e-925e-88c36a2a88cc'])
            }
            script{
                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_NAME}") {
                      docker.image("${IMAGE_NAME}:latest").pull()
                    }
            }
            post {
                success {
                    echo 'success pull image to wab server'
                }
                failure {
                    error 'fail pull image to wab server' // exit pipeline
                }
            }
        }

    }    
}