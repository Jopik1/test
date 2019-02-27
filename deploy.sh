#!/bin/sh
yum -y install python37 git wget
wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py
python3.7 -m pip install aiohttp 
python3.7 -m pip install tldextract
useradd fetch
cd ~fetch
killall python3.7
rm -rf prj
mkdir prj
cd prj
git clone https://github.com/afrmtbl/blogspot-comment-backup
chown -R fetch:fetch *
cd blogspot-comment-backup/src
su - fetch -c "cd ~/prj/blogspot-comment-backup/src; nohup python3.7 worker.py &"
