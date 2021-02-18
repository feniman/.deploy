#!/usr/bin/env bash

echo $project/$folder
sleep 1

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
	if [ ! -d $HOME"/code/"$project ]
	then
		echo "Creating "$HOME"/code/"$project
		mkdir $HOME/code/$project
	fi
	pathProj=$HOME/code/$project
else
	pathProj=$HOME/code
fi

cd $pathProj

if [ ! -d $pathProj/$folder ]
then
	echo ""
	git clone $repo
	cd $pathProj/$folder
else
	cd $pathProj/$folder
	echo ""
	echo "git pull"
	git pull
fi

git config core.fileMode false

if [ $type != "sl" ]
then
	if [ $type != "front" ]
	then
		if [ -d $pathProj/$folder/public ]
		then

			if [ ! -d $pathProj/$folder/vendor ]
			then
				echo ""
				echo "Composer"
				composer update -vvv
			else
				echo ""
				echo "Execute composer? [y/n]: "
				echo ""
				read comp
				if [ $comp = "y" ]
				then
					echo ""
					echo "Composer"
					composer update -vvv
				fi
			fi

			sudo chmod 777 $pathProj/$folder/storage -R
			sudo chown nginx:nginx $pathProj/$folder/storage -R

			if [ $type = "l1" ]
			then
				echo ""
				echo "Create Database"
#				echo "CREATE DATABASE ${folder} CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root -p "root"
				echo "CREATE DATABASE ${folder} CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql --defaults-extra-file=$HOME/.mysql-defaults-extra-file
			fi
		fi
	fi

	if [ ! -f $pathProj/.env ]
	then
		echo ""
		echo "Set .env"
		cp .env.example .env
	fi

	echo "APP_URL="$APP_URL
	echo "DB_HOST="$DB_HOST
	echo "DB_PORT="$DB_PORT
	echo "DB_DATABASE="$DB_DATABASE
	echo "DB_USERNAME="$DB_USERNAME
	echo "DB_PASSWORD="$DB_PASSWORD

	sleep 2

	if [ $type != "front" ]
	then

		while read line; do
		
			substr=$(echo $line| cut -d'=' -f 1)
			substrServer=$(echo $line| cut -d'_' -f 1)

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
				elif [ $substrServer = "SERVICE" ]
				then
					echo ${line//$line/"SRV"}
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

		sudo sed -i '/SRV/d' .env
		echo "SERVICE_L1_ACCOUNTS="$SERVICE_L1_ACCOUNTS | sudo tee -a .env
		echo "SERVICE_L1_AUTH="$SERVICE_L1_AUTH | sudo tee -a .env
		echo "SERVICE_L1_BANKSLIP="$SERVICE_L1_BANKSLIP | sudo tee -a .env
		echo "SERVICE_L1_CARDS="$SERVICE_L1_CARDS | sudo tee -a .env
		echo "SERVICE_L1_COMPANIES="$SERVICE_L1_COMPANIES | sudo tee -a .env
		echo "SERVICE_L1_CUSTOMERS="$SERVICE_L1_CUSTOMERS | sudo tee -a .env
		echo "SERVICE_L1_LOGS="$SERVICE_L1_LOGS | sudo tee -a .env
		echo "SERVICE_L1_PERSONS="$SERVICE_L1_PERSONS | sudo tee -a .env
		echo "SERVICE_L1_PRODUCTS="$SERVICE_L1_PRODUCTS | sudo tee -a .env
		echo "SERVICE_L1_SUPPLIES="$SERVICE_L1_SUPPLIES | sudo tee -a .env
		echo "SERVICE_L1_TRANSACTIONS="$SERVICE_L1_TRANSACTIONS | sudo tee -a .env
		echo "SERVICE_L2_INPAY="$SERVICE_L2_INPAY | sudo tee -a .env
		echo "SERVICE_L2_GLOBAL="$SERVICE_L2_GLOBAL | sudo tee -a .env

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
		else
			echo ""
			echo "Maestro Host: "$maestrohost
			echo "Maestro Host está correto? [y/n] (Press Enter to y)"
			read maestrohostconfirm
			if [[ $maestrohostconfirm == "n" ]]
			then
				echo ""
				echo "Maestro Host: "
				read maestrohost
			fi
		fi

		if [ -z $maestrotoken ]
		then
			if [ $folder != 'maestro' ]
			then 
				cd ~/code/maestro

				echo ""
				echo "Current Maestro Token: "
				php artisan maestro:token
				
				cd $pathProj/$folder
				echo ""
				echo "Maestro Token: "
				read maestrotoken
				
				echo "php artisan maestro:config "$maestrohost" "$maestrotoken
				php artisan maestro:config $maestrohost $maestrotoken
				php artisan maestro:register
			fi
		else
			if [ $folder != 'maestro' ]
			then 
				php artisan maestro:config $maestrohost $maestrotoken
				php artisan maestro:register
			fi
			
		fi
	fi

	if [ $folder = "maestro" ]
	then
		if [ ! -h $pathProj/$folder ]
		then
			echo ""
			echo "Link "$pathProj/$folder" in /var/www/html/"
			sudo ln -s $pathProj/$folder /var/www/html/
		fi
	else
		if [ ! -h $pathProj ]
		then
			echo ""
			echo "Link "$pathProj" in /var/www/html/"
			sudo ln -s $pathProj /var/www/html/
		fi
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



	echo ""
	echo ""
	cat /etc/hosts
	echo ""
	echo ""
	sleep 2

	sudo cp /etc/hosts ~/code

	sudo chmod 777 ~/code/hosts

	while read line; do
		if [ $line = "127.0.0.1    dev.${folder}.allapi.io" ]
		then
			sudo echo ${line//$line/""}
		else
			sudo echo $line
		fi
	done < ~/code/hosts > ~/code/hosts.t
	mv ~/code/hosts{.t,}

	sudo sed -i '/^[[:space:]]*$/d' ~/code/hosts

	echo ""
	echo "Set ~/code/hosts"
	echo "127.0.0.1    dev.${folder}.allapi.io" | sudo tee -a ~/code/hosts

	sudo cp ~/code/hosts /etc/hosts -f

	sudo rm ~/code/hosts

	echo ""
	echo "Nginx Status"
	sudo nginx -t

	echo ""
	echo ""
	cat /etc/hosts
	echo ""
	echo ""
	sleep 2

	echo ""
	echo "Nginx Reload"
	sudo systemctl reload nginx.service

	if [ $folder = 'maestro' ]
	then
		php artisan maestro:register
	fi
fi

if [ $type = "front" ]
then 
	echo ""
	echo "npm install"
	npm install
	echo ""
	echo "npm run generate"
	npm run generate
fi

echo ""
echo "Pressione qualquer tecla para continuar..."
read a


