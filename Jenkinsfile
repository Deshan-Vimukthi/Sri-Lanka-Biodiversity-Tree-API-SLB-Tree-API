pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "slb-tree-api"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        echo "Deploying DEV environment"
                        checkout([$class: 'GitSCM', branches: [[name: '*/dev']],
                                  userRemoteConfigs: [[url: 'git@your-repo.git']]])
                        env.ENV = 'dev'
                        env.COMPOSE_FILE = 'docker/docker-compose-dev.yml'
                        env.PORT = '8081'
                    }
                    else if (env.BRANCH_NAME == 'staging') {
                        echo "Deploying STAGING environment"
                        checkout([$class: 'GitSCM', branches: [[name: '*/staging']],
                                  userRemoteConfigs: [[url: 'git@your-repo.git']]])
                        env.ENV = 'staging'
                        env.COMPOSE_FILE = 'docker/docker-compose-staging.yml'
                        env.PORT = '8082'
                    }
                    else if (env.BRANCH_NAME == 'main') {
                        echo "Deploying PROD environment"
                        checkout([$class: 'GitSCM', branches: [[name: '*/main']],
                                  userRemoteConfigs: [[url: 'git@your-repo.git']]])
                        env.ENV = 'prod'
                        env.COMPOSE_FILE = 'docker/docker-compose-prod.yml'
                        env.PORT = '8083'
                    } else {
                        error "Branch ${env.BRANCH_NAME} is not allowed for deployment"
                    }
                }
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${env.BRANCH_NAME} ."
            }
        }

        stage('Deploy') {
            steps {
                script {
                    try {
                        echo "Deploying ${env.ENV} environment..."
                        sh "docker compose -f ${env.COMPOSE_FILE} down"
                        sh "docker compose -f ${env.COMPOSE_FILE} up -d --build"
                    } catch (err) {
                        echo "Deployment failed! Rolling back..."
                        rollback(env.ENV)
                        error "Deployment failed: ${err}"
                    }
                }
            }
        }
    }
}

def rollback(env) {
    echo "Executing rollback for ${env} environment..."
    if (env == 'dev') {
        sh 'docker compose -f docker/docker-compose-dev.yml down'
        sh 'docker compose -f docker/docker-compose-dev.yml up -d'
    } else if (env == 'staging') {
        sh 'docker compose -f docker/docker-compose-staging.yml down'
        sh 'docker compose -f docker/docker-compose-staging.yml up -d'
    } else if (env == 'prod') {
        sh 'docker compose -f docker/docker-compose-prod.yml down'
        sh 'docker compose -f docker/docker-compose-prod.yml up -d'
    }
}
