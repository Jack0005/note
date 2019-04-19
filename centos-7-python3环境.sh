#!/bin/bash

#替换源并生效
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
cat ./tsinghua.repo > /etc/yum.repos.d/CentOS-Base.repo
yum makecache

#安装python3
wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz
tar -xvJf  Python-3.6.8.tar.xz
cd Python-3.6.8
./configure --prefix=/usr/local/python3
make && make install

ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
pip3 install --upgrade pip


#安装依赖包
pip3 install numpy
pip3 install scipy
pip3 install matplotlib
pip3 install pandas
pip3 install statsmodels
pip3 install scikit-learn
pip3 install theano
pip3 install keras
pip3 install gensim
pip3 install tensorflow
