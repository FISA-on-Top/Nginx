pipeline{
    agent any   
    environment {
        DEV_FRONT_SERVER_IP = '43.201.20.90' 
    }
    stages {
        stage('build for feature/deploy'){
            agent none
            steps{
                git branch : 'feature/deploy',
                //credentialsId: '',
                url : 'https://github.com/FISA-on-Top/Nginx.git'
            }
            steps{
                sh 'docker build --no-cache -t nginx_react:latest .'
            }
           
            // steps {
            //     echo " Execute shell start"
            //     sshagent(credentials: ['devfront-server']) {
            //         sh '''
            //             ssh -o StrictHostKeyChecking=yes ubuntu@${DEV_FRONT_SERVER_IP} '
            //             cp -r ~/nginx/build ~/build
            //             docker stop web_server || true
            //             docker rm -f web_server || true
            //             sudo rm -rf ~/nginx || true
            //             git clone -b feature/deploy https://github.com/FISA-on-Top/Nginx.git 
            //             cd nginx
            //             docker rmi nginx_react:latest || true
            //             docker build --no-cache -t nginx_react .
            //             docker run -d --user 1000:1000 -p 80:80 -v ~/nginx/build:/usr/share/nginx/html --name web_server nginx_react
            //             cp -r ~/build ~/nginx/build
            //             rm -rf ~/build/
            //             '
            //         '''               
            //     }
            //     echo " Execute shell end"
            // }
        
        }
    }
}