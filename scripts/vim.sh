#!/usr/bin/env bash

echo ">>> Setting up Vim"

if [[ -z $1 ]]; then
    resources_url="https://nrq.me/scripts/vagrant"
else
    resources_url="$1"
fi

# Create directories needed for some .vimrc settings
mkdir -p /home/vagrant/.vim/backup
mkdir -p /home/vagrant/.vim/swap

# Install Vundle and set owner of .vim files
git clone -q https://github.com/VundleVim/Vundle.vim.git /home/vagrant/.vim/bundle/vundle
sudo chown -R vagrant:vagrant /home/vagrant/.vim

# Grab .vimrc and set owner
curl --silent -L $resources_url/helpers/vimrc > /home/vagrant/.vimrc
sudo chown vagrant:vagrant /home/vagrant/.vimrc

# Install Vundle Bundles
sudo su - vagrant -c 'vim +PluginInstall +qall'
