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
