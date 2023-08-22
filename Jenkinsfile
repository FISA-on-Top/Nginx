pipeline{
    agent any   
    environment {
        DEV_FRONT_SERVER_IP = '43.201.20.90' 
    }
    stages {
        stage('for deploy nginx in dev server'){
            steps {
                echo " Execute shell start"
                sshagent(['6418520a-09b4-481e-925e-88c36a2a88cc']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=yes ubuntu@${DEV_FRONT_SERVER_IP} '
                        cp ~/nginx/build ~/build
                        docker stop web_server || true
                        docker rm -f web_server || true
                        rm -rf nginx/ || true
                        git clone https://github.com/FISA-on-Top/Nginx.git nginx
                        cd nginx
                        docker rmi nginx_react:latest || true
                        docker build --no-cache -t nginx_react .
                        docker run -d -p 80:80 -v ~/nginx/build:/usr/share/nginx/html --name web_server nginx_react
                        cp ~/build ~/nginx/build
                        rm -rf ~/build/
                        '
                    '''               
                }
                echo " Execute shell end"
            }
        
        }
    }
}