def label = "eosagent"
def mvn_version = 'M2'
podTemplate(label: label, yaml: """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: build
  annotations:
    sidecar.istio.io/inject: "false"
spec:
  containers:
  - name: build
    image: bahaamri97/eos-jenkins-agent-base:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
"""
) {
    node (label) {

        stage ('Checkout SCM'){
          git credentialsId: 'git', url: 'https://gitlab.com/shopping_portal/gateway-api-service.git', branch: 'master'
          container('build') {
            stage('Build a Maven project') {
              sh './mvnw clean package' 
            }
          }
        }


        stage ('Sonar Scan'){
          container('build') {
            withSonarQubeEnv('sonar') {
              sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=tuto-eos_eos'
            }
          }
        }


        stage ('Artifactory configuration'){
          container('build') {
            withCredentials([usernamePassword(credentialsId: 'jfrog', usernameVariable: 'username', passwordVariable: 'password')]) {
              sh './mvnw clean install'
              sh 'curl -sSf -u $username:$password -X PUT -T target/gateway-0.0.1-RELEASE.jar "https://tutoartifacts.jfrog.io/artifactory/eos-libs-release-local/gateway-0.0.1-RELEASE.jar"'
            }
          }
        }


        stage ('Build Image'){
          container('build') {
            docker.withRegistry( 'https://registry.hub.docker.com', 'docker' ) {
              def customImage = docker.build("bahaamri97/eos-gateway-api:latest")
              customImage.push()             
            }
          }
        }


        stage ('Helm Chart') {
          container('build') {
            dir('charts') {
              withCredentials([usernamePassword(credentialsId: 'jfrog', usernameVariable: 'username', passwordVariable: 'password')]) {
              sh '/usr/local/bin/helm package gateway-api'
              sh '/usr/local/bin/helm push-artifactory gateway-api-1.0.tgz https://tutoartifacts.jfrog.io/artifactory/eos-helm-local --username $username --password $password'
              }
            }
          }
        }
    }
}
