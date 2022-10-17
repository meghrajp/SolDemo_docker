pipeline {
    agent any
    environment {
        JURL = 'http://artifactory-unified.soleng-us.jfrog.team/'
        RT_URL = 'http://artifactory-unified.soleng-us.jfrog.team/artifactory'
        TOKEN = credentials('art_token')
        ARTIFACTORY_LOCAL_DEV_REPO = 'soldocker-demo-dev'
        SERVER_ID = 'k8s'
        BUILD_NAME = "SolDemo_docker_maven"
    }
    tools {
        maven "maven-3.6.3"
    }
 
    stages {
        stage ('Config JFrgo CLI') {
            steps {
                
                sh 'jf c add ${SERVER_ID} --interactive=false --overwrite=true --access-token=${TOKEN} --url=${JURL}'
                sh 'jf config use ${SERVER_ID}'
            }
        }
        stage ('Ping to Artifactory') {
            steps {
               sh 'jf rt ping'
            }
        }
        stage ('Config Maven'){
            steps {
                dir('complete'){
                    sh 'jf mvnc --repo-resolve-releases=soldocker-demo-virtual --repo-resolve-snapshots=soldocker-demo-virtual --repo-deploy-releases=soldocker-demo-virtual --repo-deploy-snapshots=soldocker-demo-virtual'
                }
            }
        }
        stage('Compile') {
            steps {
                echo 'Compiling'
                //dir('complete') {
                    sh 'jf mvnc'
                    sh 'jf mvn clean install -f complete/ -Dcheckstyle.skip -DskipTests'
               // }
            }
        }
        stage ('Upload artifact') {
            steps {
               // dir('complete') {
                    sh 'jf mvnc'
                    sh 'jf mvn clean deploy complete/ -Dcheckstyle.skip -DskipTests --build-name="${BUILD_NAME}" --build-number=${BUILD_ID}'
               // }
            }
        }
        stage ('Publish build info') {
            steps {
                // Collect environment variables for the build
                sh 'jf rt bce "${BUILD_NAME}" ${BUILD_ID}'
                //Collect VCS details from git and add them to the build
                sh 'jf rt bag "${BUILD_NAME}" ${BUILD_ID}'
                //Publish build info
                sh 'jf rt bp "${BUILD_NAME}" ${BUILD_ID} --build-url=${BUILD_URL}'
                //Promote the build
                sh 'jf rt bpr --status=Development --props="status=Development" "${BUILD_NAME}" ${BUILD_ID} ${ARTIFACTORY_LOCAL_DEV_REPO}'
            }
        }
    }
}
