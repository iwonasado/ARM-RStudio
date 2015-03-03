#!/bin/bash
#This script installs R and builds RStudio Desktop for ARM Chromebooks running Ubuntu 14.04

#Install R
sudo apt-get update
sudo apt-get install -y r-base r-base-dev

#Download RStudio source
#Set RStudio version
#VERS=v0.98.982
VERS=v0.99.320
cd
wget https://github.com/rstudio/rstudio/tarball/$VERS
mkdir rstudio-$VERS && tar xvf $VERS -C rstudio-$VERS --strip-components 1
rm $VERS

#Install RStudio build dependencies
sudo apt-get install -y git
sudo apt-get install -y build-essential pkg-config fakeroot cmake ant libjpeg62
sudo apt-get install -y uuid-dev libssl-dev libbz2-dev zlib1g-dev libpam-dev
sudo apt-get install -y libapparmor1 apparmor-utils libboost-all-dev libpango1.0-dev
sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y cabal-install
sudo apt-get install -y ghc
sudo apt-get install -y qt-sdk
sudo apt-get install -y pandoc

sudo apt-get install libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libqt5svg5-dev libqt5xmlpatterns5-dev

#Run common environment preparation scripts
cd rstudio-$VERS/dependencies/common/
mkdir ~/rstudio-$VERS/dependencies/common/pandoc
cd ~/rstudio-$VERS/dependencies/common/
./install-gwt
./install-dictionaries
./install-mathjax
./install-boost
./install-packages

#cd ~/rstudio-$VERS/dependencies/linux/
#./install-dependencies-debian

#Get Closure Compiler and replace compiler.jar
cd
wget http://dl.google.com/closure-compiler/compiler-latest.zip
unzip compiler-latest.zip
rm COPYING README.md compiler-latest.zip
sudo mv compiler.jar ~/rstudio-$VERS/src/gwt/tools/compiler/compiler.jar

#Configure cmake and build RStudio
cd ~/rstudio-$VERS/
mkdir build
cd ~/rstudio-$VERS/build
sudo cmake .. -DRSTUDIO_TARGET=Desktop -DCMAKE_BUILD_TYPE=Release
sudo make install

#Clean the system of packages used for building
cd
sudo apt-get autoremove -y cabal-install ghc openjdk-7-jdk pandoc libboost-all-dev
sudo rm -r -f rstudio-$VERS
sudo apt-get autoremove -y
