pipeline{
    agent any   

    environment{
        //REPOSITORY_CREDENTIAL_ID = 'gitlab-jenkins-key'
        NGINX_URL = 'https://github.com/FISA-on-Top/Nginx.git'
        WEB_URL = 'https://github.com/FISA-on-Top/frontend.git'
        //TARGET_BRANCH = 'main' 

        AWS_CREDENTIAL_NAME = 'ECR-access'
        ECR_NAME = 'AWS'
        ECR_PATH = '038331013212.dkr.ecr.ap-northeast-2.amazonaws.com'
        
        IMAGE_VERSION = "0.${BUILD_NUMBER}"
        REGION = 'ap-northeast-2'
    }
    stages{
        
        stage('Build Docker Image for Prod server'){
            when{
                branch 'main'
            }
            environment {
                IMAGE_NAME = 'front'
            }
            steps{
                echo 'Clone'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.BRANCH_NAME]],
                    userRemoteConfigs: [[url: WEB_URL]]
                ])

                echo 'Build'
                script{
                    sh '''
                    # docker build -f Dockerfile_Production --no-cache -t ${IMAGE_NAME}:${IMAGE_VERSION} .
                    docker build -f Dockerfile_Production --no-cache -t ${IMAGE_NAME}:latest .
                    # docker tag $IMAGE_NAME:$IMAGE_VERSION $ECR_PATH/$IMAGE_NAME:$IMAGE_VERSION
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

        stage('Build Docker Image for Dev server'){
            when{
            //     anyOf {
            //         changeset "dockerfile"
            //         changeset "conf/*"
            //     }
                branch 'develop'
            }
            environment {
                IMAGE_NAME = 'nginx'
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

        stage('Push to ECR for Prod server') {
            when{
            //     anyOf {
            //         changeset "dockerfile"
            //         changeset "conf/*"
            //     }
                branch 'main'
            }
            environment {
                IMAGE_NAME = 'front'
            }
            steps {
                script {
                    // cleanup current user docker credentials
                    sh 'rm -f ~/.dockercfg ~/.docker/config.json || true'

                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_NAME}") {
                      docker.image("${IMAGE_NAME}:${IMAGE_VERSION}").push()
                      docker.image("${IMAGE_NAME}:latest").push()
                    }
                }
            }
            post {
                always{
                    // sh("docker rmi -f ${ECR_PATH}/${IMAGE_NAME}:${IMAGE_VERSION}")
                    sh("docker rmi -f ${ECR_PATH}/${IMAGE_NAME}:latest")
                    // sh("docker rmi -f ${IMAGE_NAME}:${IMAGE_VERSION}")
                    sh("docker rmi -f ${IMAGE_NAME}:latest")
                }
                success {
                    echo 'success upload image'
                }
                failure {
                    error 'fail upload image' // exit pipeline
                }
            }
        }        
        stage('Push to ECR for Dev server') {
            when{
            //     anyOf {
            //         changeset "dockerfile"
            //         changeset "conf/*"
            //     }
                branch 'develop'
            }
            environment {
                IMAGE_NAME = 'nginx'
            }             
            steps {
                script {
                    // cleanup current user docker credentials
                    sh 'rm -f ~/.dockercfg ~/.docker/config.json || true'

                    docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_NAME}") {
                      docker.image("${IMAGE_NAME}:${IMAGE_VERSION}").push()
                      docker.image("${IMAGE_NAME}:latest").push()
                    }
                }
            }
            post {
                always{
                    sh("docker rmi -f ${ECR_PATH}/${IMAGE_NAME}:${IMAGE_VERSION}")
                    sh("docker rmi -f ${ECR_PATH}/${IMAGE_NAME}:latest")
                    sh("docker rmi -f ${IMAGE_NAME}:${IMAGE_VERSION}")
                    sh("docker rmi -f ${IMAGE_NAME}:latest")
                }
                success {
                    echo 'success upload image'
                }
                failure {
                    error 'fail upload image' // exit pipeline
                }
            }
        }

        stage('Pull and Delpoy to Devfront server') {
            when {
                branch 'develop'
                // anyOf {
                //     branch 'feature/*'
                //     branch 'develop'
                // }
            }  
            environment {
                IMAGE_NAME = 'nginx'
                WEBSERVER_USERNAME = 'ubuntu'
                WEBSERVER_IP = '43.201.20.90' 
                CONTAINER_NAME = 'webserver'
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
                            docker run -d \
                            -p 80:80 \
                            -p 3000:3000 \
                            -v ~/nginx/log:/var/log/nginx \
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