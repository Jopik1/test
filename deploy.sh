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

cat > runloop.sh <<EOL
#!/bin/bash
cd ~/prj/blogspot-comment-backup/src
while true
do
	python3.7 worker.py
	sleep 1
done
EOL

su - fetch -c "nohup ~/prj/blogspot-comment-backup/src/runloop.sh &"

nohup tail -f ~fetch/prj/blogspot-comment-backup/src/nohup.out | >/dev/tty1 2>&1 &

