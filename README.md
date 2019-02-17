# keepalived_redis_nginx
keepalived+redis+nginx deployment example

OS: Centos7.5

* master ip: 10.211.55.5
* slave ip: 10.211.55.6
* vip: 10.211.55.10


### keepalived install
```bash
yum -y install libnl libnl-devel libnfnetlink-devel openssl-devel net-tools
tar -xvf keepalived-2.0.11.tar.gz
cd keepalived-2.0.11
./configure --prefix=/usr/local/keepalived
make
make install
```

setup keepalived service
```
cp keepalived/etc/init.d/keepalived /etc/init.d/
cp keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived

systemctl start keepalived
systemctl enable keepalived
```

### redis install
```bash
tar -xvf redis-4.0.12.tar.gz
cd redis-4.0.12
make PREFIX=/usr/local/redis install
mv redis.conf /usr/local/redis/
mv sentinel.conf /usr/local/redis/
ln -s /usr/local/redis/bin/redis-cli /usr/bin/redis-cli
```

setup redis service
```bash
vim /usr/lib/systemd/system/redis.service
```

```vim
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
PIDFile=/var/run/redis/redis_6379.pid
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/redis.conf
ExecStop=/usr/local/redis/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
```

```
systemctl daemon-reload
systemctl start redis
systemctl enable redis
```

### python3 install
```bash
yum install  bzip2-devel ncurses-devel sqlite-devel gdbm-devel xz-devel tk-devel readline-devel openssl-devel -y
tar -xvf Python-3.6.8.tar.xz
cd Python-3.6.8
./configure --prefix=/usr/local/python3.6.8
vim Modules/Setup
make
make install
/usr/local/python3.6.8/bin/pip3 install virtualenv
ln -s /usr/local/python3.6.8/bin/python3 /usr/bin/python3
ln -s /usr/local/python3.6.8/bin/virtualenv /usr/bin/virtualenv
```

Or this way

```bash
#!/bin/bash

# install-python3.sh
# package/rpm_python/*.rpm
# package/Python-3.6.8.tar.xz

rpm -Uvh ./package/rpm_python/*.rpm
tar -xvf ./package/Python-3.6.8.tar.xz
cd Python-3.6.8
./configure --prefix=/usr/local/python3.6.8
vi Modules/Setup
make
make install
cd ../package
/usr/local/python3.6.8/bin/pip3 install virtualenv-16.2.0-py2.py3-none-any.whl
ln -s /usr/local/python3.6.8/bin/python3 /usr/bin/python3
ln -s /usr/local/python3.6.8/bin/virtualenv /usr/bin/virtualenv
cd ../
rm -rf Python-3.6.8
```

### supervisor install
```bash
yum install python-pip -y
pip install supervisor
vim /usr/lib/systemd/system/supervisord.service
```

### nginx install
```bash
yum install epel-release -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
```

or this way
```bash
yum install  bzip2-devel ncurses-devel sqlite-devel gdbm-devel xz-devel tk-devel readline-devel openssl-devel -y
yum install -y gcc gcc-c++

tar -xvf pcre-8.42.tar.gz
tar -xvf zlib-1.2.11.tar.gz
tar -xvf nginx-1.14.2.tar.gz

./configure --sbin-path=/usr/local/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre=../pcre-8.42 --with-zlib=../zlib-1.2.11 --with-http_ssl_module --with-stream
make 
make install
```

```bash
vim /usr/lib/systemd/system/nginx.service
```

```vim
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /var/run/nginx/nginx.pid
ExecStartPre=/usr/local/sbin/nginx -t
ExecStart=/usr/local/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

```bash
systemctl start nginx
```


### keepalived+redis+nginx config
master
```bash
git clone https://github.com/Glf9832/keepalived_redis_nginx.git
mkdir /etc/keepalived/
mv keepalived_redis_nginx/master/keepalived/keepalived.conf /etc/keepalived/
mv keepalived_redis_nginx/master/keepalived/scripts /etc/keepalived/
chmod +x /etc/keepalived/scripts/*

mv -f keepalived_redis_nginx/master/nginx.conf /etc/nginx/
mv -f keepalived_redis_nginx/master/redis.conf /usr/local/redis/
mkdir /var/log/keepalived
```

slave
```bash
git clone https://github.com/Glf9832/keepalived_redis_nginx.git
mkdir /etc/keepalived/
mv keepalived_redis_nginx/slave/keepalived/keepalived.conf /etc/keepalived/
mv keepalived_redis_nginx/slave/keepalived/scripts /etc/keepalived/
chmod +x /etc/keepalived/scripts/*

mv -f keepalived_redis_nginx/slave/nginx.conf /etc/nginx/
mv -f keepalived_redis_nginx/slave/redis.conf /usr/local/redis/
mkdir /var/log/keepalived
```

### start services
```bash
uwsgi --wsgi-file manage.py --callable app --processes 4 --threads 2 --socket localhost:9000 --daemonize uwsgi.log
systemctl restart nginx
# /usr/local/redis/bin/redis-server /usr/local/redis/redis.conf
systemctl restart redis
# /usr/local/keepalived/sbin/keepalived -f /etc/keepalived/keepalived.conf
systemctl restart keepalived


systemctl start supervisord
```

## Other install

### vimplus install
update to vim8.0
```bash
rpm -Uvh http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm
rpm --import http://mirror.ghettoforge.org/distributions/gf/RPM-GPG-KEY-gf.el7
yum -y remove vim-minimal vim-common vim-enhanced
yum -y --enablerepo=gf-plus install vim-enhanced
```

```bash
unzip vim.zip
cd vim
mv vimrc ~/.vimrc
mv vimrc.local ~/.vimrc.local
cd ..
mv vim ~/.vim
mv ~/.vim/plugged/YouCompleteMe/ ~/.vim/plugged/YouCompleteMe.bak
```

