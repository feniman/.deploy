#!/usr/bin/env bash

if [ -d $HOME/code ]
then
	echo ""
	echo "chown $USER:$GROUP $HOME/code -R"
	sudo chown $USER:$GROUP $HOME/code -R

fi

if [ -d $HOME/code/${folder} ]
then
	echo ""
	echo "chown $USER:$GROUP $HOME/code/${folder} -R"
	sudo chown $USER:$GROUP $HOME/code/${folder} -R

	echo ""
	echo "Remove $HOME/code/${folder}"
	sudo rm $HOME/code/${folder} -rf
fi

if [ -h /var/www/html/${folder} ]
then
	echo ""
	echo "chown $USER:$GROUP /var/www/html/${folder} -R"
	sudo chown $USER:$GROUP /var/www/html/${folder} -R

	echo ""
	echo "Remove /var/www/html/${folder}"
	sudo rm /var/www/html/${folder} -rf
fi

echo ""
echo "Drop Database"
echo "DROP DATABASE ${folder};" | mysql -u root -p

if [ -h /etc/nginx/sites-enabled/dev.${folder}.allapi.io.conf ]
then
	echo ""
	echo "Remove /etc/nginx/sites-enabled/dev.${folder}.allapi.io.conf"
	sudo rm /etc/nginx/sites-enabled/dev.${folder}.allapi.io.conf -rf
fi

if [ -f /etc/nginx/sites-available/dev.${folder}.allapi.io.conf ]
then
	echo ""
	echo "Remove /etc/nginx/sites-available/dev.${folder}.allapi.io.conf"
	sudo rm /etc/nginx/sites-available/dev.${folder}.allapi.io.conf -rf
fi

if [ -f /var/log//nginx/dev.${folder}.allapi.io.access.log ]
then
	echo ""
	echo "Remove dev.${folder}.allapi.io.access.log"
	sudo rm /var/log//nginx/dev.${folder}.allapi.io.access.log
fi

if [ -f /var/log//nginx/dev.${folder}.allapi.io.error.log ]
then
	echo ""
	echo "Remove dev.${folder}.allapi.io.error.log"
	sudo rm /var/log//nginx/dev.${folder}.allapi.io.error.log
fi

sudo sed -i -e 's/127.0.0.1    dev.${folder}.allapi.io//g' /etc/hosts

sudo sed -i '/^[[:space:]]*$/d' /etc/hosts

echo ""
echo "Status Nginx"
sudo nginx -t

echo ""
echo "Reload Nginx"
sudo systemctl reload nginx.service

# echo "127.0.0.1    dev.${folder}.allapi.io" | sudo tee -a /etc/hosts

cd $HOME