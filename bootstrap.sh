#!/bin/bash -eu

release_src=https://github.com/downloads/Graylog2
graylog2_server=graylog2-server-0.9.4p1.tar.gz
graylog2_web_interface=graylog2-web-interface-0.9.4p2.tar.gz

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install python-software-properties
sudo add-apt-repository 'deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
sudo apt-get update

for pkg in wget build-essential make rrdtool openjdk-6-jre ruby1.8 rubygems rake libopenssl-ruby libmysqlclient-dev ruby-dev libapache2-mod-passenger mongodb-stable mysql-server
do
  sudo apt-get install -y $pkg
done

for dir in src rrd
do
  sudo mkdir -pv /var/graylog2/$dir
done

cd /var/graylog2/src

for remote_pkg in $release_src/graylog2-server/$graylog2_server $release_src/graylog2-web-interface/$graylog2_web_interface
do
  sudo wget --no-check-certificate $remote_pkg
done

for tar in $graylog2_server $graylog2_web_interface
do
  sudo tar -xvf $tar
  folder=`echo $tar | sed 's/.tar.gz//; s!.*/!!'`
  if echo $folder | grep -q 'server'
  then
    sudo ln -sf src/$folder ../server
  else
    sudo ln -sf src/$folder ../web
  fi
done

sudo gem install rubygems-update
sudo /var/lib/gems/1.8/bin/update_rubygems

for gem in bundler bluepill
do
  sudo gem install $gem
done

cd ../web
sudo bundle install

fqdn=`hostname --fqdn`

sudo sed -e 's/root/graylog2/g' -i config/database.yml
sudo sed -e 's/yourpass/Gr4yl0g2p455wD/g' -i config/database.yml
sudo sed -e 's/your-graylog2.example.org/$fqdn/g' -i config/general.yml

sudo chown -R nobody:nogroup /var/graylog2

exit 0
