pipeline {
    environment {
        nexusRegfluentd = "3.87.171.0:8082/fluentd"
        nexusReg = "3.87.171.0:8082"
    }
    agent {
        node {
            label 'logging'
        }
    }
    stages {
        stage('Clone Git Project') {
            steps {
                git url: 'https://github.com/hosseinkarjoo/DevOps-Training-Full-Deployment.git', branch: 'Logging', credentialsId: 'github_creds'
            }
        }
        stage ('image cleanup') {
            steps {
                script {
                    try {
                        sh'docker image rmi $(docker image ls -qa) --force'
                    }
                    catch (err) {
                        echo: 'ERRORR'
                    }
                }
            }
        }          
        stage ('Build') {
            steps {
                script {
                    sh 'docker build -t ${nexusRegfluentd}:${BUILD_NUMBER} .'
                }
            }
        }
        stage ('Third - Push Images to DockerHub') {
            steps {
                script {
//                    withCredentials([usernamePassword(credentialsId: 'nexusReg-Creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                    sh'docker login -u "admin" -p "123@qwer" http://${nexusReg}/repository/docker-reg'
                    sh 'docker push ${nexusRegfluentd}:${BUILD_NUMBER}'
//                    }
                    
                }
            }
        }
        stage ('Deploy') {
            steps {
                script {
                    try {
                        sh'docker-compose down'
                        sh'docker-compose rm --force'
                        sh'docker stack rm ek'
                    }
                    catch (err) {
                        echo: 'EROR'
                    }    
                    sh'docker stack deploy --compose-file docker-compose-ek.yml ek'
                }
            }
        }
//        stage ('test - groovy') {
 //           agent {label 'logging'}
  //              steps {
   //                 script {
    //                    Node_IP=InetAddress.localHost.hostAddress
     //                   println InetAddress.localHost.hostAddress
      //                  LOGGING_PRV_IP = sh (
       //                     script: "/usr/sbin/ifconfig | grep '10.0.1' | /usr/bin/awk '{print \$2}'" ,
        //                    returnStdout: true
         //               )
          //              sh"echo $LOGGING_PRV_IP > TEST.txt"
           //         }
          //      }
     //   }    
    }
}
