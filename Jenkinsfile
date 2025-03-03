pipeline{
    agent{
        label "node"
    }
    stages{
        stages {
            stage('Checkout') {
                steps {
                    git branch: 'main', url: 'https://github.com/venky9143/my-solar-system.git'
                }
            }
            stage('install dependencies'){
                steps{
                    sh 'npm install'
                }
                
            }
            stage(' dependencies scanning '){
                steps{
                    sh 'npm audit'
                }
            }
        }
    }
}