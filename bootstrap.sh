#!/bin/bash -eu

release_src=https://github.com/downloads/Graylog2
graylog2_server=graylog2-server-0.9.4p1.tar.gz
graylog2_web_interface=graylog2-web-interface-0.9.4p2.tar.gz
graylog2_base=/var/graylog2

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install python-software-properties
sudo add-apt-repository 'deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
sudo apt-get update

for pkg in wget build-essential make rrdtool openjdk-6-jre ruby1.8 rubygems rake libopenssl-ruby libmysqlclient-dev ruby-dev libapache2-mod-passenger postfix mongodb-stable mysql-server
do
  sudo apt-get install -y $pkg
done

sudo mkdir -pv $graylog2_base/src $graylog2_base/rrd

cd $graylog2_base/src

sudo wget --no-check-certificate $release_src/graylog2-server/$graylog2_server -O $graylog2_server
sudo tar -xvf $graylog2_server
folder=`echo $graylog2_server | sed 's/.tar.gz//; s!.*/!!'`
sudo ln -sf $graylog2_base/src/$folder $graylog2_base/server

sudo wget --no-check-certificate $release_src/graylog2-web-interface/$graylog2_web_interface -O $graylog2_web_interface
sudo tar -xvf $graylog2_web_interface
folder=`echo $graylog2_web_interface | sed 's/.tar.gz//; s!.*/!!'`
sudo ln -sf $graylog2_base/src/$folder $graylog2_base/web

sudo gem install rubygems-update
sudo /var/lib/gems/1.8/bin/update_rubygems

for gem in bundler bluepill
do
  sudo gem install $gem
done

sudo mv -f $graylog2_base/server/graylog2.conf.example $graylog2_base/server/graylog2.conf
sudo ln -s $graylog2_base/server/graylog2.conf /etc/graylog2.conf

cd $graylog2_base/web

sudo bundle install

fqdn=`hostname --fqdn`

sudo sed -e "s/root/graylog2/g" -i config/database.yml
sudo sed -e "s/yourpass/Gr4yl0g2p455wD/g" -i config/database.yml
sudo sed -e "s/your-graylog2.example.org/$fqdn/g" -i config/general.yml

sudo chown -R nobody:nogroup $graylog2_base

exit 0
