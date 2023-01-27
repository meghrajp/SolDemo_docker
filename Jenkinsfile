pipeline {
    agent any
    environment {
        JURL = 'https://soleng.jfrog.io/'
        RT_URL = 'https://soleng.jfrog.io/artifactory'
        TOKEN = credentials('art_token')
        ARTIFACTORY_LOCAL_DEV_REPO = 'meghraj-docker-local'
        ARTIFACTORY_DOCKER_REGISTRY = 'meghraj-docker-local.soleng.jfrog.io'
        DOCKER_REPOSITORY = 'meghraj-docker-local'
        IMAGE_NAME = 'meghraj_docker_demo'
        IMAGE_VERSION = '1.0.0'
        SERVER_ID = 'k8s'
        BUILD_NAME = "meghraj_docker_maven_new"
    }
    tools {
        maven "maven-3.8.6"
        //maven MAVEN_TOOL
    }
 
    stages {
        stage ('Config JFrog CLI') {
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
                    sh 'jf mvnc --repo-resolve-releases=meghraj-docker --repo-resolve-snapshots=meghraj-docker --repo-deploy-releases=meghraj-docker --repo-deploy-snapshots=meghraj-docker'
                }
            }
        }
        stage('Compile') {
            steps {
                echo 'Compiling'
                dir('complete') {
                    //sh 'jf mvnc'
                    sh 'jf mvn clean test-compile -Dcheckstyle.skip -DskipTests'
                }
            }
        }
        stage('Package') {
            steps {
                dir('complete') {
                //Before creating the docker image, we need to create the .jar file
                   // sh 'jf mvnc'
                    sh 'jf mvn package spring-boot:repackage -DskipTests -Dcheckstyle.skip'
                  //  sh "./mvnw package"
                    echo 'Create the Docker image'
                   // sh "docker build -t build_promotion ."
                    script {
                        docker.build(ARTIFACTORY_DOCKER_REGISTRY+'/'+IMAGE_NAME+':'+IMAGE_VERSION, '--build-arg JAR_FILE=target/*.jar ../.')
                    }
                }
            }
        }
        
        stage ('Push image to Artifactory') {
            steps {
                sh 'export DOCKER_OPTS+=" --insecure-registry ${ARTIFACTORY_DOCKER_REGISTRY}"'
                sh 'docker login -u meghrajp -p ${TOKEN} ${ARTIFACTORY_DOCKER_REGISTRY}'
              //  sh 'docker push ${ARTIFACTORY_DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}'
                sh 'jf rt docker-push ${ARTIFACTORY_DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION} ${DOCKER_REPOSITORY} --build-name="${BUILD_NAME}" --build-number=${BUILD_ID} --url ${RT_URL} --access-token ${TOKEN}'
       
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
