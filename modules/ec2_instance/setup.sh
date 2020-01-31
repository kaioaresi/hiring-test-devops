#!/bin/bash
set -e

remove_apache2() {

  r_apache2=$(sudo systemctl stop apache2 ; sudo systemctl disable apache2 ; sudo apt-get remove --purge apache* -y 2>&1 >> /tmp/aqui.txt)
  logger "######## Remove apache2 ########"
  if `$r_apache2`; then
    logger "######## Removed apache2 ########"
    sudo apt-get autoremove -y
  else
    logger "######## Error to remove apache2 ########"
  fi
  logger "######## Done iniciada ########"
}

add_modules() {

  modules_k8s=$(echo -e "br_netfilter\nip_vs_rr\nip_vs_wrr\nip_vs_sh\nnf_conntrack_ipv4\nip_vs" > /etc/modules-load.d/k8s.conf)
  logger "######## Start Add modules ########"
  if `$r_apache2`; then
    logger "######## Modules add ########"
  else
    logger "######## Error to add modules add ########"
  fi
  logger "######## Done Add modules ########"
}

basic_itens(){

  disable_swap=$(sudo swapoff -a 2>&1 >> /tmp/aqui.txt)
  basic_packs=$(sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common 2>&1 >> /tmp/aqui.txt)

  if `$disable_swap`; then
    sudo apt-get update 2>&1 >> /tmp/aqui.txt
    sudo apt-get upgrade -y 2>&1 >> /tmp/aqui.txt
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common 2>&1 >> /tmp/aqui.txt
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 2>&1 >> /tmp/aqui.txt
    sudo add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    logger "repository docker and k8s"
    echo "repository docker and k8s"
    sudo apt-get update 2>&1 >> /tmp/aqui.txt
    sudo apt-get install -y docker-ce kubelet kubeadm kubectl 2>&1 >> /tmp/aqui.txt
    logger "######## Usermod start!"
    echo "######## Usermod start!"
    sudo usermod -aG docker $USER
    logger "######## Usermod done!"
    echo "######## Usermod done!"
    logger "######## Basic process success!"
  else
    logger "######## Basic process Fail!"
  fi
}

# functions
remove_apache2
add_modules
basic_itens
