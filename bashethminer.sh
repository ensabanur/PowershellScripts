#!/bin/sh
git clone https://github.com/Genoil/cpp-ethereum.git
cd cpp-ethereum
mkdir build; cd build
cmake ..
cmake --build .
sudo make install