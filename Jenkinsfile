pipeline {

  agent {
    label "kube-node"
  }

  options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
      disableConcurrentBuilds()
  }

  environment {
    currentAppVersion = '1.0-SNAPSHOT'
  }

  stages {

    stage('prep workspace') {
      steps {
        deleteDir()
      }
    }

    stage('checkout repo') {
      steps {
  			container(name: 'maven', shell: '/bin/bash') {
          git branch: 'develop', url: 'https://github.com/naveenjilla/cicd-poc'
          /*script {
            pomInfo = readMavenPom file: 'pom.xml'
            currentAppVersion=pomInfo.version
          }*/
        }
      }
    }

    stage('compile') {
      steps {
        container(name: 'maven', shell: '/bin/bash') {
          script {
            sh ("mvn clean package -DskipTests")
          }
        }
      }
    }

    stage('test') {
      parallel {
        stage ('owasp testing') {
          steps {
            script {
              echo "owasp testing..."
            }
          }
        }
        stage ('sonar testing') {
          steps {
            script {
              echo "sonar testing..."
            }
          }
        }
        stage ('nexusiq testing') {
          steps {
            script {
              echo "nexusiq testing..."
            }
          }
        }
      }
    }

    stage('connect GKE and GCR ') {
      steps {
  			container(name: 'maven', shell: '/bin/bash') {
          sh 'gcloud auth activate-service-account --key-file /secrets/cicd-demo1-0a0981c1f737.json'
          sh 'gcloud container clusters get-credentials cicd-poc --zone us-central1-a --project cicd-demo1'
          sh 'cat /secrets/cicd-demo1-0a0981c1f737.json | docker login -u _json_key --password-stdin https://gcr.io'
        }
      }
    }

    stage('image') {
      steps {
        container(name: 'maven', shell: '/bin/bash') {
          script {
            sh 'docker build -t gcr.io/cicd-demo1/hello-docker:${currentAppVersion} .'
  					sh 'docker push gcr.io/cicd-demo1/hello-docker:${currentAppVersion}'
          }
        }
      }
    }

    stage('deploy') {
      steps {
        container(name: 'maven', shell: '/bin/bash') {
          script {
            sh 'sed -i s/hello-docker:0/hello-docker:${currentAppVersion}/g app.yaml'
            sh 'kubectl apply -f app.yaml -n hwdevns'
          }
        }
      }
    }
  }
/*
  post {
    always {
      deleteDir ()
    }
  }
*/
}
