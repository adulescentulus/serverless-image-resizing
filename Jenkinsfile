pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '15'))
    }
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                    '''
            }
        }
        stage('Build') {
            agent {
                docker { 
                    image 'lambci/lambda:build-nodejs6.10'
                    reuseNode true 
                }
            }
            steps {
                sh '''
                    export HOME=/tmp
                    cd lambda
                    npm install --production
                    zip -r ../dist/function.zip *
                    '''
            }
        }
        stage('Deploy') {
            agent {
                docker { 
                    image 'grolland/aws-cli'
                    reuseNode true 
                }
            }
            environment {
                AWS_DEFAULT_REGION = 'eu-central-1'
                AWS_ACCESS_KEY_ID = credentials('AWS_KEY_IMGRESIZE_ID')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_KEY_IMGRESIZE_KEY')
                STACK_NAME = 'BNC-ServerlessImageResize'
            }
            steps {
                s3Upload consoleLogLevel: 'INFO', dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'cfn-infra-jenkins-artifacts', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: true, noUploadOnFailure: true, selectedRegion: 'eu-central-1', showDirectlyInBrowser: false, sourceFile: 'dist/*.zip', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 'ARTIFACTS', userMetadata: []
                sh '''
                    bin/deploy 
                    '''
            }
        }
    }
    post { 
        always { 
            cleanWs()
        }
    }
}