pipeline {

  agent {
    label "kube-node"
  }

  options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
      disableConcurrentBuilds()
  }

  environment {
    currentAppVersion = '1.0.1'
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
/*
    stage('create release branch') {
      when {
        expression {
          branch.matches ('master')
        }
      }
      steps {
        container(name: 'maven', shell: '/bin/bash') {
        script {
          currentVersion=currentAppVersion.replace ("-SNAPSHOT", "")
          print "currentVersion=${currentVersion}"

          checkVersion = sh(script: "git branch -r | egrep 'origin/${currentVersion}' | grep -v 'x' | cut -f3- -d. | sort --version-sort | tail -1", returnStdout:true)
          if(checkVersion == '')
            newMinorVersion = '0'.toInteger()
          else
            newMinorVersion = checkVersion.toInteger()+1

          newAppVersion = "${currentVersion}.${newMinorVersion}"
          echo "Creating version: ${newAppVersion}"

          sh "git checkout -b ${newAppVersion}"
          sh "mvn versions:set -DnewVersion=${newAppVersion} -DgenerateBackupPoms=false"
          sh "git commit -am \"Auto: created release branch ${newAppVersion}\""
          sh "git config --get remote.origin.url"
          sh "git push --set-upstream origin ${newAppVersion}"
          }
        currentAppVersion = "${newAppVersion}"
        }
      }
    }
*/
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
            sh 'kubectl apply -f app.yaml -n hwprodns'
          }
        }
      }
    }
  }

}
