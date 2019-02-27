#!/bin/sh
yum -y install python37 git wget
wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py
python3.7 -m pip install aiohttp 
python3.7 -m pip install tldextract
useradd fetch
cd ~fetch
killall python3.7
sleep 5
killall -9 python3.7
sleep 5
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
chmod +x runloop.sh
su - fetch -c "nohup ~/prj/blogspot-comment-backup/src/runloop.sh &"

cd ~

cat > logtotty1.sh <<EOL
#!/bin/bash
while true
do
  date > /dev/tty1
  echo "Worker log" > /dev/tty1
	tail  ~fetch/nohup.out  >/dev/tty1 2>&1 &
	sleep 60
done
EOL
chmod +x logtotty1.sh


nohup ./logtotty1.sh &

