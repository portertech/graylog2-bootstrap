#!/bin/bash -eu

release_src=https://github.com/downloads/Graylog2
graylog2_server=graylog2-server-0.9.4p1.tar.gz
graylog2_web_interface=graylog2-web-interface-0.9.4p2.tar.gz
graylog2_base=/var/graylog2
graylog2_collection_size=650000000

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
sudo gem install bundler

cd $graylog2_base/server

sudo mv -f graylog2.conf.example graylog2.conf
sudo sed -e "s/true/false/" -i graylog2.conf
sudo sed -e "s/50000000/$graylog2_collection_size/" -i graylog2.conf
sudo ln -sf $graylog2_base/server/graylog2.conf /etc/graylog2.conf

cd bin && sudo ./graylog2ctl start

cd $graylog2_base/web

sudo bundle install

sudo sed -e "s/yourpass//" -i config/database.yml
fqdn=`hostname --fqdn`
sudo sed -e "s/your-graylog2.example.org/$fqdn/" -i config/general.yml

export RAILS_ENV=production

sudo chown -R nobody:nogroup $graylog2_base

sudo -u nobody rake db:create
sudo -u nobody rake db:migrate

exit 0
