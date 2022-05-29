pipeline {
    environment {
//        regAddr = '780067648615.dkr.ecr.us-east-1.amazonaws.com'
        regAddr = readFile '/tmp/outputs'
        dockerAddr = readFile '/tmp/Docker-addr.txt'
    }
    agent {
        node {
            label 'prod'
        }
    }
    stages {
        stage('Clone Git Project') {
            steps {
                git url: 'https://github.com/hosseinkarjoo/Personal-Project-Docker-Stack-Flask-app.git', branch: 'master'
                sh'echo ${regAddr}'
            }
        }
//        stage ('image cleanup') {
 //           steps {
  //              script {
   //                 try {
    //                    sh'docker image rmi $(docker image ls -qa) --force'
     //               }
      //              catch (err) {
       //                 echo: 'ERRORR'
        //            }
         //       }
          //  }
       // }          
        stage ('Build') {
            steps {
                script {
                    sh 'docker-compose build '
                }
            }
        }
        stage ('Login to ECR') {
            steps {
                script {
                    sh 'whoami'
                    sh 'ls ~/.aws'
                    sh 'aws ecr get-login-password --region us-east-1 --profile cloud_user | docker login --username AWS --password-stdin ${regAddr}/app'
                    sh 'aws ecr get-login-password --region us-east-1 --profile cloud_user | docker login --username AWS --password-stdin ${regAddr}/api'
                    sh 'aws ecr get-login-password --region us-east-1 --profile cloud_user | docker login --username AWS --password-stdin ${regAddr}/db'
                }
            }
        }
        stage ('Third - Push Images to DockerHub') {
            steps {
                script {
//                    withCredentials([usernamePassword(credentialsId: 'nexusReg-Creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                    sh 'docker-compose push'
//                    }
                    
                }
            }
        }
        stage ('provision Configs') {
            steps {
                script {
                    sh 'sed -ie "s/dockerAddr/${dockerAddr}/g" ./monitoring/prometheus.yml'
                    sh 'sed -ie "s/dockerAddr/${dockerAddr}/g" ./monitoring/datasource.yml'
                    sh 'sed -ie "s/localhost/${dockerAddr}/g" ./logging/kibana.yml'
                }
            }
        }
        stage ('Deploy') {
            steps {
                script {
                    try {
                        sh'docker-compose down'
                        sh'docker-compose rm --force'
                    }
                    catch (err) {
                        echo: 'EROR'
                    }    
                    sh'docker stack deploy --compose-file docker-compose-stack.yml flask_app'
                }
            }
        }
        stage ('Deploy to Minoting-Stack') {
            steps {
                script {
//                    try {
//                        sh'docker-compose down'
 //                       sh'docker-compose rm --force'
  //                  }
 //                   catch (err) {
 //                       echo: 'EROR'
 //                   }
                    sh'docker stack deploy --compose-file ./monitoring/docker-compose-monitoring-stack.yml monitoring'
                }
            }
        }
        stage ('Deploy Logging-stack') {
            steps {
                script {
//                    try {
//                        sh'docker-compose down'
 //                       sh'docker-compose rm --force'
  //                  }
 //                   catch (err) {
 //                       echo: 'EROR'
 //                   }
                    sh'docker stack deploy --compose-file ./logging/docker-compose-ek.yml logging'
                }
            }
        }
        stage ('test and deploy logging') {
            steps {
                script {
                   if [ netstat -tulpn | grep 24224 ] ; then
                       sh 'sudo mv /etc/docker/daemon-test.json /etc/docker/daemon.json'
                       sh 'sudo sed -ie "s/localhost/${dockerAddr}/" /etc/docker/daemon.json'
                   else
                       echo 'Fluent D is not running'
                }
            }
        }
//       stage ('test') {
//           steps {
//              script {
//                 try {
//                sh'timeout 5s docker container run -i --rm --network flask_app_main-net mikesplain/telnet flask_app_devops-training-app 80 > /tmp/mysql-test'
//               }
//              catch (err) {
//                 echo: 'ERRORR'
//            }
//           sh'cat /tmp/mysql-test | grep Connect'
//      }
// }
// }
    }
}

