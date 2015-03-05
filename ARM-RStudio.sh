#!/bin/bash
#This script installs R and builds RStudio Desktop for ARM Chromebooks running Ubuntu 14.04

# usage info
usage()
{
	echo -e "\nUsage: $(basename $0) [VERS] [CLEAN]\n"
	echo -e "VERS: Set vx.xx.xxx for RStudio version [default: v0.98.982]"
	echo -e "CLEAN: Set 1 to clean packages used for building [default: 1]\n"
}

#Set RStudio version
#VERS=v0.99.323
VERS=v0.98.982
CLEAN=1
if [ $# -gt 0 ]; then
  if [ $# -eq 2 ]; then
    VERS=$1
    CLEAN=$2
  else
    usage
  fi
fi

#Install R
sudo apt-get update
sudo apt-get install -y r-base r-base-dev

#Download RStudio source
cd
wget https://github.com/rstudio/rstudio/tarball/$VERS

# check if source code has been successfuly downloaded
if [ -f $VERS ]; then
  mkdir rstudio-$VERS && tar xvf $VERS -C rstudio-$VERS --strip-components 1
  rm $VERS
else
  echo -e "invalid RStudio version or download failed!\n"
  usage
fi

#Install RStudio build dependencies
sudo apt-get install -y git
sudo apt-get install -y build-essential pkg-config fakeroot cmake ant libjpeg62
sudo apt-get install -y uuid-dev libssl-dev libbz2-dev zlib1g-dev libpam-dev
sudo apt-get install -y libapparmor1 apparmor-utils libboost-all-dev libpango1.0-dev
sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y cabal-install
sudo apt-get install -y ghc
sudo apt-get install -y pandoc

sudo apt-get install -y qtcreator qt-sdk qtbase5-dev qttools5-dev qttools5-dev-tools qttools5-private-dev
sudo apt-get install libqt5webkit5-dev qtpositioning5-dev libqt5sensors5-dev libqt5svg5-dev libqt5xmlpatterns5-dev

if [$VERS -eq "v0.98.982"]; then
  ## For old versions with QT4
  # Q_WS_X11 not set if qt5 is installed
  sudo apt-get remove qtbase5-dev
  # Make sure libqt4-dev is installed
  sudo apt-get install qt4-dev
else
  ## For new versions with QT5
  # Patch CMakeLists.txt
  sed -i 's|get_filename_component|#get_filename_component|g' ~/rstudio-$VERS/src/cpp/desktop/CMakeLists.txt
  sed -i 's|set(CMAKE_PREFIX_PATH "${QT_BIN_DIR}//..//lib//cmake")|set(CMAKE_PREFIX_PATH "/usr")|g' ~/rstudio-$VERS/src/cpp/desktop/CMakeLists.txt
fi

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
if [CLEAN -eq 1]; then
  cd
  sudo apt-get autoremove -y cabal-install ghc openjdk-7-jdk pandoc libboost-all-dev
  sudo rm -r -f rstudio-$VERS
  sudo apt-get autoremove -y
fi
