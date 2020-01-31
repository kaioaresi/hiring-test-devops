#!/bin/bash
set -e

kubeadm join 172.31.82.20:6443 --token ft84a7.fyf0z196kybjyyei --discovery-token-ca-cert-hash sha256:9ac82c5c4e0402d5696f1eeabc5848f545c68bf9aec1b5a46f613bb61650402e
