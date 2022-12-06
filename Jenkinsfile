pipeline {
    agent any
    environment {
        JURL = 'http://artifactory-unified.soleng-us.jfrog.team/'
        RT_URL = 'http://artifactory-unified.soleng-us.jfrog.team/artifactory'
        TOKEN = credentials('art_token')
        ARTIFACTORY_LOCAL_DEV_REPO = 'soldocker-demo-dev'
        ARTIFACTORY_DOCKER_REGISTRY = 'soldocker-demo-dev.artifactory-unified.soleng-us.jfrog.team'
        DOCKER_REPOSITORY = 'soldocker-demo-dev'
        IMAGE_NAME = 'sol_docker_demo'
        IMAGE_VERSION = '1.0.0'
        SERVER_ID = 'k8s'
        BUILD_NAME = "SolDemo_docker_maven_new"
    }
    tools {
        maven "maven-3.6.3"
        //maven MAVEN_TOOL
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
                sh 'export DOCKER_OPTS+=" --insecure-registry soldocker-demo-dev.artifactory-unified.soleng-us.jfrog.team"'
                sh 'docker login -u admin -p JFr0g0601 soldocker-demo-dev.artifactory-unified.soleng-us.jfrog.team'
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
