#!/usr/bin/env bash

clear

source $HOME/.deploy/.formatting

project=InfinityPay
folder=maestro
	
echo -e "${u}Normal${reset} ${u}${blink}Blink${reset} Normal"

if [ -z ${project+x} ]; then echo "project is unset"; else echo "project is set to '$project'"; fi

INPUT='DB_USERNAME=homestead'
SUBSTRING=$(echo $INPUT| cut -d'=' -f 1)
echo $SUBSTRING

APP_URL="dev.${folder}.allapi.io"

DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=maestro
DB_USERNAME=asd
DB_PASSWORD=asd


while read line; do
	
	substr=$(echo $line| cut -d'=' -f 1)

	if [ ! -z $substr ]
	then
	    if [ $substr = "APP_URL" ]
		then
	    	echo ${line//$line/"APP_URL="$APP_URL}
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

done < $HOME/.deploy/.env > $HOME/.deploy/.env.t
mv $HOME/.deploy/.env{.t,}