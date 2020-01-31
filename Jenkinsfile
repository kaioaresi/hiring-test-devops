def LABEL_ID = "slave-avec-app-${UUID.randomUUID().toString()}"

podTemplate(label: LABEL_ID,yaml: """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker-container
    image: docker
    command: ['cat']
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  - name: kubectl-container
    image: gcr.io/cloud-builders/kubectl
    command: ['cat']
    tty: true
  volumes:
    - name: dockersock
      hostPath:
        path: /var/run/docker.sock
""")
{
  node(LABEL_ID){
    checkout scm

    stage('Build image') {
      container('docker-container'){
        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USER')]) {
          sh 'docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}'
          sh 'docker build -t ${DOCKER_HUB_USER}/avec ./app'
          sh "docker image push ${DOCKER_HUB_USER}/avec"
        }
      }
    }

    stage('Deploy') {
      container('kubectl-container'){
        withKubeConfig([credentialsId: 'jenkins-sa', serverUrl: env.K8S_URL]) {
          parallel(
            app_deployment: {
              sh 'kubectl -n default apply -f app_k8s/app_deployment.yaml'
            },
            app_service: {
              sh 'kubectl -n default apply -f app_k8s/app_service.yaml'
            }
          )
        }
      }
    }

  }//node
}
