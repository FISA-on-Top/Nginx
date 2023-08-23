pipeline{
    agent any   

    stages{
        stage('Clone'){
            steps{
                echo 'Clone'
                git branch: 'feature/deploy', 
                url: 'https://github.com/FISA-on-Top/Nginx.git'
            }
        }
    }    
}