#!/bin/bash

## zsh 
apt install -y zsh 
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
echo Y | sh install.sh

## zsh alias completion

echo "alias k=kubectl" >> ~/.zshrc
echo "alias kcd='kubectl  config  set-context  $(kubectl  config current-context) --namespace'" >> ~/.zshrc 
echo "source <(kubectl completion zsh)" >> ~/.zshrc
echo "source <(kubeadm completion zsh)" >> ~/.zshrc
echo "source <(helm completion zsh)" >> ~/.zshrc
