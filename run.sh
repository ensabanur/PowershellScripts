#!/bin/bash
sudo apt-get update
sudo apt-get -qq dist-upgrade
sudo apt-get -qq install gcc g++ build-essential libssl-dev automake linux-headers-generic git gawk libcurl4-openssl-dev libjansson-dev xorg libc++-dev libgmp-dev python-dev dkms
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/384.66/NVIDIA-Linux-x86_64-384.66.run
sudo chmod +x NVIDIA-Linux-x86_64-384.66.run
sudo ./NVIDIA-Linux-x86_64-384.66.run --no-install-compat32-libs --no-x-check -a -n -q -s
wget https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64-deb
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64-deb
sudo apt-get update
sudo apt-get -qq install cuda-toolkit-8-0
sudo usermod -a -G video $USER
echo "" >> ~/.bashrc
echo "export PATH=/usr/local/cuda-8.0/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda8.0/lib64:$LD_LIBRARY_PATH" >> ~/.bashrc
sudo apt-get -qq update
sudo apt-get -qq install cmake
mkdir ~/ethminer; cd ~/ethminer
git clone https://github.com/ethereum-mining/ethminer
cd ethminer
mkdir build; cd build
cmake .. -DETHASHCUDA=ON -DETHASHCL=ON
cmake --build .
sudo make install