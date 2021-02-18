#!/bin/bash

if [ -d $HOME"/code/"$project/$folder ]
then


	if [ -d $HOME/code ]
	then
		echo ""
		echo "chown $USER:$GROUP $HOME/code -R"
		sudo chown $USER:$GROUP $HOME/code -R

	fi

	if [ ! -z ${project+x} ]
	then
		echo "Remove "$HOME"/code/"$project/$folder
		rm -rf $HOME"/code/"$project/$folder
		pathProj=$HOME/code/$project
	else
		pathProj=$HOME/code
	fi

	cd $pathProj


	if [ -d $HOME/code/${folder} ]
	then
		echo ""
		echo "chown $USER:$GROUP pathProj/${folder} -R"
		sudo chown $USER:$GROUP pathProj/${folder} -R

		echo ""
		echo "Remove pathProj/${folder}"
		sudo rm pathProj/${folder} -rf
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

	if [ $type = "l1" ]
	then
		echo ""
		echo "Drop Database"
		echo "DROP DATABASE ${folder};" | mysql --defaults-extra-file=$HOME/.mysql-defaults-extra-file
	fi

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
		sudo rm /var/log/nginx/dev.${folder}.allapi.io.access.log
	fi

	if [ -f /var/log//nginx/dev.${folder}.allapi.io.error.log ]
	then
		echo ""
		echo "Remove dev.${folder}.allapi.io.error.log"
		sudo rm /var/log/nginx/dev.${folder}.allapi.io.error.log
	fi

	sudo sed -i -e 's/127.0.0.1    dev.${folder}.allapi.io//g' /etc/hosts

	sudo sed -i '/^[[:space:]]*$/d' /etc/hosts

	echo ""
	echo "Status Nginx"
	sudo nginx -t

	echo ""
	echo "Reload Nginx"
	sudo systemctl reload nginx.service

	echo ""
	echo "Pressione qualquer tecla para continuar..."
	read a
fi
