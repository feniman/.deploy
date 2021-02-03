#!/usr/bin/env bash

if [ ! -d $HOME/code ]
then
	echo ""
	echo "Creating "$HOME"/code"
	mkdir $HOME/code
	echo ""
	echo "Set permission in "$HOME"/code"
	sudo chmod 777 /home && sudo chmod 777 /home/$USER && sudo chmod 777 /home/$USER/code
	sudo chown nginx:nginx $HOME/code -R
	echo ""
	echo "sudo -u nginx stat $HOME/code"
	sudo -u nginx stat $HOME/code

	echo ""
	echo "sudo -u "$USER" stat $HOME/code"
	sudo -u $USER stat $HOME/code
fi

if [ ! -z ${project+x} ]
then
	echo "Creating "$HOME"/code/"$project
	mkdir $HOME/code/$project
	pathProj=$HOME/code/$project
else
	pathProj=$HOME/code
fi

cd $pathProj

if [ ! -d $pathProj/$folder ]
then
	echo ""
	git clone $repo
fi

cd $pathProj/$folder

if [ -d $pathProj/$folder/public ]
then

	if [ ! -d $pathProj/$folder/vendor ]
	then
		echo ""
		echo "Composer"
		composer update -vvv
	else
		read -p comp "Execute composer? [y/n]: "
		if [ $comp == "y" ]
		then
			echo ""
			echo "Composer"
			composer update -vvv
		fi
	fi


	if [ $type = "l1" ]
	then
		echo ""
		echo "Create Database"
		echo "CREATE DATABASE ${folder} CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root -p
	fi

	if [ ! -f $pathProj/.env ]
	then
		echo ""
		echo "Set .env"
		cp .env.example .env
	fi

	while read line; do
	
		substr=$(echo $line| cut -d'=' -f 1)

		if [ ! -z $substr ]
		then
			if [ $substr = "APP_URL" ]
			then
		    	echo ${line//$line/"APP_URL="$APP_URL}
		    elif [ $substr = "DB_HOST" ]
			then
		    	echo ${line//$line/"DB_HOST="$DB_HOST}
			elif [ $substr = "DB_PORT" ]
			then
		    	echo ${line//$line/"DB_PORT="$DB_PORT}
		    elif [ $substr = "DB_DATABASE" ]
			then
		    	echo ${line//$line/"DB_DATABASE="$DB_DATABASE}
		    elif [ $substr = "DB_USERNAME" ]
			then
		    	echo ${line//$line/"DB_USERNAME="$DB_USERNAME}
		    elif [ $substr = "DB_PASSWORD" ]
			then
		    	echo ${line//$line/"DB_PASSWORD="$DB_PASSWORD}
		    else
		    	echo $line
		    fi
	    fi
	    if [ -z $line ]
	    then
	    	echo $line
	    fi
	done < .env > .env.t
	mv .env{.t,}

	if [ $type = "l1" ]
	then
		php artisan migrate:fresh
		php artisan db:seed
	fi

	php artisan key:generate

	php artisan maestro:key --set

	if [ $folder = 'maestro' ]
	then 
		maestrohost=$APP_URL
	fi
		
	if [ -z $maestrohost ]
	then
		echo ""
		echo "Maestro Host: "
		read maestrohost
	fi

	if [ -z maestrotoken ]
	then
		if [ $folder != 'maestro' ]
		then 
			cd ~/code/maestro
			php artisan maestro:token
			cd $pathProj/$folder
		fi
		echo ""
		echo "Maestro Token: "
		read maestrotoken
		
		php artisan maestro:config maestrohost maestrotoken
		
		php artisan maestro:register
	fi


	if [ ! -h /var/www/html/$folder ]
	then
		echo ""
		echo "Link ~/code/${folder} in /var/www/html/"
		sudo ln -s $pathProj /var/www/html/
	fi

	if [ ! -f /etc/nginx/sites-available/dev.$folder.allapi.io.conf ]
	then
		echo ""
		echo "Creating Nginx .conf to "$folder
		sudo cp $configPath/dev.$folder.allapi.io.conf /etc/nginx/sites-available/
	fi

	if [ ! -h /etc/nginx/sites-enabled/dev.$folder.allapi.io.conf ]
	then
		echo ""
		echo "Link Nginx .conf between sites-available and sites-enabled"
		sudo ln -s /etc/nginx/sites-available/dev.$folder.allapi.io.conf /etc/nginx/sites-enabled/
	fi

	sudo sed -i -e 's/127.0.0.1    dev.${folder}.allapi.io//g' /etc/hosts

	sudo sed -i '/^[[:space:]]*$/d' /etc/hosts

	echo ""
	echo "Set /etc/hosts"
	echo "127.0.0.1    dev.${folder}.allapi.io" | sudo tee -a /etc/hosts

	echo ""
	echo "Nginx Status"
	sudo nginx -t

	echo ""
	echo "Nginx Reload"
	sudo systemctl reload nginx.service

	if [ $folder = 'maestro' ]
	then
		php artisan maestro:register
	fi
fi

echo ""
echo "Pressione qualquer tecla para continuar..."
read asd


