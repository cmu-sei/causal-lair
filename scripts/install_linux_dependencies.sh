#!/bin/bash

# install instructions for AIR

sudo apt update
sudo apt upgrade -y

### install R 
#########################################################

# update repository for R
sudo apt update -qq

sudo apt install --no-install-recommends software-properties-common dirmngr

wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# install R
sudo apt install -y --no-install-recommends r-base

#########################################################



### install quarto 
#########################################################

wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb

sudo apt-get install -y ./quarto-1.5.57-linux-amd64.deb
#sudo dpkg -i quarto-1.5.57-linux-amd64.deb

#########################################################



#########################################################
### next, navigate to directory where AIRTool_v2.qmd lives
#########################################################



### install R dependencies 
#########################################################

sudo apt-get -y install libcurl4-openssl-dev libssl-dev libxml2-dev build-essential libfontconfig1-dev zlib1g-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev gfortran liblapack-dev libopenblas-dev librsvg2-dev pandoc default-jdk libtirpc-dev

sudo Rscript scripts/install_dependencies.R

#########################################################



#### to run: 
#########################################################

# this will need to go in a bash script to be run
# quarto preview AIRTool_v2.qmd --server

#########################################################