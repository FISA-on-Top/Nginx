pipeline{
    agent any   

    environment{
        //REPOSITORY_CREDENTIAL_ID = 'gitlab-jenkins-key'
        REPOSITORY_URL = 'https://github.com/FISA-on-Top/Nginx.git'
        //TARGET_BRANCH = 'main' 

        AWS_CREDENTIAL_NAME = 'ECR-access'
        ECR_NAME = 'AWS'
        ECR_PATH = '038331013212.dkr.ecr.ap-northeast-2.amazonaws.com'
        IMAGE_NAME = 'nginx'
        IMAGE_VERSION = "0.${BUILD_NUMBER}"
        REGION = 'ap-northeast-2'

        WEBSERVER_USERNAME = 'ubuntu'
        WEBSERVER_IP = '43.201.20.90' 
        CONTAINER_NAME = 'webserver'
    }
    stages{
        stage('Build Docker Image'){
            when{
                // Dockerfile에 대한 변경 사항이 있는 경우에만 실행
                changeset "dockerfile"
            }            
            steps{
                script{
                    sh '''
                    docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_VERSION} .
                    docker build -t ${IMAGE_NAME}:latest .
                    docker tag $IMAGE_NAME:$IMAGE_VERSION $ECR_PATH/$IMAGE_NAME:$IMAGE_VERSION
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
            when{
                // Dockerfile에 대한 변경 사항이 있는 경우에만 실행
                changeset "dockerfile"
            }
            steps {
                script {
                    // cleanup current user docker credentials
                    sh 'rm -f ~/.dockercfg ~/.docker/config.json || true'

                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_NAME}") {
                      docker.image("${IMAGE_NAME}:${IMAGE_VERSION}").push()
                      docker.image("${IMAGE_NAME}:latest").push()
                    }

                    sh("docker rmi -f ${ECR_PATH}/${IMAGE_NAME}:${IMAGE_VERSION}")
                    sh("docker rmi -f ${ECR_PATH}/${IMAGE_NAME}:latest")
                    sh("docker rmi -f ${IMAGE_NAME}:${IMAGE_VERSION}")
                    sh("docker rmi -f ${IMAGE_NAME}:latest")
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
        stage('Pull and Delpoy to Web server') {
            when {
                //branch 'develop'
                anyOf {
                    branch 'feature/*'
                    branch 'develop'
                }
            }            
            steps{
                echo "Current branch is ${env.BRANCH_NAME}"

                sshagent(credentials:['devfront']){
                        sh """                      
                            ssh -o StrictHostKeyChecking=no $WEBSERVER_USERNAME@$WEBSERVER_IP '
                            ls
                            
                            # Login to ECR and pull the Docker image
                            echo "login into aws"
                            aws ecr get-login-password --region $REGION | docker login --username $ECR_NAME --password-stdin $ECR_PATH
                            
                            # Pull image from ECR to web server
                            echo "pull the image from ECR"
                            docker pull $ECR_PATH/$IMAGE_NAME:latest
                            
                            # Remove the existing container, if it exists\
                            echo "remove docker container if it existes"
                            if docker ps -a | grep $CONTAINER_NAME; then
                                docker rm -f $CONTAINER_NAME
                            fi

                            # Run a new Docker container using the image from ECR
                            echo "docker run"
                            docker run \
                            -p 80:80 \
                            -p 3000:3000 \
                            -v ~/nginx/log:/var/log/nginx/log \
                            -v ~/nginx/build:/usr/share/nginx/html \
                            --name $CONTAINER_NAME $ECR_PATH/$IMAGE_NAME:latest
                            '
                        """
                }
            }
            post{
                success {
                    echo 'success pull a image from ECR to web server'
                }
                failure {
                    error 'fail pull a image from ECR to web server' // exit pipeline
                }
            }
        }

    }    
}