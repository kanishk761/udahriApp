sudo apt-get update
sudo apt-get install apache2
sudo apt-get install libapache2-mod-wsgi-py3
sudo apt-get install python3-pip
sudo pip3 install flask
sudo pip3 install cassandra-driver
sudo apt-get install python3-tk
sudo pip3 install firebase-admin
sudo pip3 install python-dateutil
mkdir ~/src
sudo ln -sT ~/src /var/www/html/src
mv app.py src/
mv flaskapp.wsgi src/
mv sf-class2-root.crt src/
cd ~/src
mv flaskapp.wsgi app.wsgi
sudo cp ../000-default.conf /etc/apache2/sites-enabled/000-default.conf
sudo service apache2 restart
