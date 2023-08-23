pipeline{
    agent any   

    stages {
        stage('checkout'){
            steps{
                git branch : 'feature/deploy',
                //credentialsId: '',
                url : 'https://github.com/FISA-on-Top/Nginx.git'
            }
            steps{
                sh 'docker build --no-cache -t nginx_react:latest .'
            }        
        }
    }
}