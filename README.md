# Hiring Test - DevOps

No diretório [app](./app) temos uma aplicação em NodeJS que responde
o clima atual de uma cidade, através da rota `/search?q=CIDADE`, rodando por padrão na porta 8000.

O teste consiste em fornecer uma solução completa para rodar essa aplicação na **AWS**, com foco em IaC, escalabilidade e CI / CD. **Alta performance é imprescindível!**

O teste deverá ser entregue **"pronto para uso"**, onde poderemos facilmente realizar o deploy para um stage `dev` ou para `production`.

- A aplicação deverá rodar em um container docker, utilizando o [Dockerfile](./app/Dockerfile) já existente.
- A infraestrutura deverá ser criada com alguma ferramenta de IaC (Terraform, Cloudformation, Ansible, Pulumi, CDK, ...).
- Fornecer ou detalhar soluções para monitoramento e gerenciamento de logs.
- Continuous Deploy é essencial! Github Actions, GitLab CI, TravisCI, CircleCI, Jenkins. Fornecer uma solução de fácil utilização para atualização da infraestrutura e da aplicação.
- Realizar as correções necessárias no projeto atual.
- Soluções serverless serão bem vindas.
- Preparar um README **bem elaborado** com o passo a passo para subir a aplicação para um stage `dev` ou para `production`.
- Boas práticas e padrões são **imprescindíveis** em todos os processos!

Para realizar o teste, deve-se fazer um fork deste repositório, realizar as alteraçoes necessárias e enviar o link do seu fork para [jacqueline.mello@avecbrasil.com.br](mailto:jacqueline.mello@avecbrasil.com.br).

---
# App

Endereço: <IP>:31000

---

# Terraform

# Procedimentos de instalação

1 - Criando o bucket para armazenar nosso remote `tfstate`

```
cd ./aws/bucket
terraform init
terraform apply -var-file ../envs/envs.tfvars
```

2 - Criando Instancias e autoscaling

```
cd ./aws/k8s
terraform init -backend-config ../envs/backend_k8s.vars
terraform apply -var-file ../envs/envs.tfvars
```
---

# Instanlando k8s

> Um script é executado no momento da criação de cada instancia.

## Master

```
kubeadm config images pull
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl get nodes
kubeadm token create --print-join-command
```

---
# Helm

```
curl -L https://git.io/get_helm.sh | bash
helm init --client-only
helm plugin install https://github.com/rimusz/helm-tiller
```

## Helm tillerless

```
helm tiller start <namespace>
helm tiller start # por defaul é sempre criado no ns `kube-system`
```

---

# Monitoring

Precisamos apenas criar o ns

> Dir: `tools/monitoring/`

```
kubectl create ns monitoring
```

## Prometheus


Aqui realizamos a implementação do `prometheus` via helm

```
helm install --name prometheus --namespace monitoring stable/prometheus -f prometheus_values.yaml
```

## Grafana

Aqui realizamos a implementação do `grafana` via helm

```
helm install --name grafana --namespace monitoring stable/grafana -f grafana_values.yaml
```

![Alt monitoring](https://miro.medium.com/max/842/1*5UjMzRYBLsMiRxZtcza52g.png)

## Endereços

```
Prometheus: http://<IP>:31010
Grafana: http://<IP>:31020
  admin/123456
```

---

# Logging

> Dir: `tools/logging/`

```
kubectl create ns logging
```

## Elasticsearch

```
helm install stable/elasticsearch --namespace logging --name elasticsearch -f elastic.yaml
```

## Kibana

```
helm install --name kibana stable/kibana --namespace logging -f kibana.yaml
```

## Fluentd

```
helm install stable/fluentd-elasticsearch --name fluentd --namespace logging
```

![Alt loggin](https://mherman.org/assets/img/blog/kibana/fluentd-kubernetes.png)

## Endereços

```
Kibana: http://<IP>:31030
```

## CI/CD

```
kubectl create ns cicd
```

### Jenkins

Dir: `tools/cicd/`

```
helm install --name jenkins --namespace cicd stable/jenkins -f jenkins_values.yaml
```

### Credenciais `kubectl`

```
kubectl -n default create serviceaccount jenkins
kubectl -n default create rolebinding jenkins-binding --clusterrole=cluster-admin --serviceaccount=default:jenkins
kubectl -n default create rolebinding jenkins-binding --clusterrole=cluster-admin --serviceaccount=default:jenkins
```

```
kubectl -n kube-system get sa jenkins -o yaml
kubectl -n kube-system describe secrets jenkins-token-XXXXX
```

---

# Criando user dev

Certificado

```
openssl req -new -newkey rsa:4096 -nodes -keyout dev.key -out dev.csr -subj "/CN=dev/O=dev"
openssl x509 -req -in dev.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out dev.crt -days 365
cp /etc/kubernetes/pki/ca.crt ./k8s.crt
```

```
cat <<EOF> dev-csr.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: dev-access
spec:
  groups:
  - system:authenticated
  request: $(cat dev.csr | base64 | tr -d '\n')
  usages:
  - client authcertificatesigningrequest.certificates.k8s.io/dev-access created
EOF
```

```
kubectl create -f dev-csr.yaml
kubectl get csr
kubectl certificate approve dev-access
kubectl get csr
```

```
kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=k8s.crt --kubeconfig=dev-config --embed-certs

kubectl config set-credentials dev --client-certificate=dev.crt --client-key=dev.key --embed-certs --kubeconfig=dev-config

kubectl config set-context dev --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}') --namespace=dev --user=dev --kubeconfig=dev-config
```

Validando
```
kubectl config use-context dev --kubeconfig=dev-config
kubectl version --kubeconfig=dev-config
kubectl -n dev get pods --kubeconfig=dev-config
```

Aplicando as roles `rbac_dev.yaml`

```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dev-role
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["services","pods","secrets","configmaps","secrets","deployments","services"]
  verbs: ["get", "list","watch","create","update","patch","delete"]
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["get", "list","watch","create","update","patch","delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-role-binding
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dev-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: dev
  namespace: dev
```

```
kubectl create -f rbac_dev.yaml
```

Validando permissões

```
kubectl -n dev get pods --kubeconfig=dev-config
```

---

# Referencias

- https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-2-elasticsearch-configuration/
- https://mherman.org/blog/logging-in-kubernetes-with-elasticsearch-Kibana-fluentd/
- https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-1-fluentd-architecture-and-configuration/
- https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes-pt
- https://medium.com/@jbsazon/aggregated-kubernetes-container-logs-with-fluent-bit-elasticsearch-and-kibana-s5a9708c5dd9a
- https://medium.com/better-programming/k8s-tips-give-access-to-your-clusterwith-a-client-certificate-dfb3b71a76fe
- https://www.openlogic.com/blog/granting-user-access-your-kubernetes-cluster
- https://medium.com/@rodrigogrohl/liberando-novos-acessos-ao-kubernetes-chave-certificado-roles-e-contexto-3c1b86a90625
- https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html
- https://codefarm.me/2019/02/01/access-kubernetes-api-with-client-certificates/
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/
