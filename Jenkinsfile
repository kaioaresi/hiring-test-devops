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
        sh 'docker build -t kaioaresi/avec ./app'
      }
    }

  }//node
}
