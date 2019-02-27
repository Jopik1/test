#!/bin/sh
yum -y install python37 git wget psmisc
chage --lastday 100000 root
wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py
python3.7 -m pip install aiohttp 
python3.7 -m pip install tldextract
useradd fetch
cd ~fetch
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

cd ~
cat > logtotty1.sh <<EOL
#!/bin/bash
while true
do
  date > /dev/tty1
  tail -n 500 ~fetch/nohup.out | grep BATCH | tail -n 1 >/dev/tty1 2>&1 
	tail  ~fetch/nohup.out  >/dev/tty1 2>&1 
	ls -ltra /home/fetch/prj/blogspot-comment-backup/output/  >/dev/tty1 2>&1 
	sleep 10
done
EOL
chmod +x logtotty1.sh

cat > service.sh <<EOL
#!/bin/bash
cd ~fetch/prj/blogspot-comment-backup/
git pull 
su - fetch -c "~/prj/blogspot-comment-backup/src/runloop.sh > ~/nohup.out 2>&1 &" &
cd ~
su - root -c "./logtotty1.sh" &
sleep 259200
shutdown -p
EOL
chmod +x service.sh

cat > service_stop.sh <<EOL
#!/bin/bash
/usr/bin/killall runloop.sh
/usr/bin/killall logtotty1.sh
/usr/bin/killall python3.7
sleep 10
/usr/bin/killall -9 python3.7
EOL
chmod +x service_stop.sh


cat >/etc/systemd/system/worker.service <<EOL
[Unit]
Description=download worker
After=multi-user.target

[Service]
ExecStart=/root/service.sh
ExecStop=/usr/bin/echo "ExecStop"
ExecStopPost=/usr/bin/echo "ExecStopPost"

[Install]
WantedBy=default.target
EOL

systemctl daemon-reload
systemctl enable worker.service
systemctl daemon-reload
systemctl stop worker.service
systemctl start worker.service

