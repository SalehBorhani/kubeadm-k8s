#!/bin/bash

## zsh 
apt update && apt install -y zsh git
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
echo Y | sh install.sh

## zsh alias completion

echo "alias k=kubectl" >> ~/.zshrc
echo "alias kcd='kubectl  config  set-context  $(kubectl  config current-context) --namespace'" >> ~/.zshrc 
echo "source <(kubectl completion zsh)" >> ~/.zshrc
