#!/bin/bash

header()
{
	echo ""
	echo " DEPLOY ${company} v${version} "
	echo ""
	if [ -z $prod ]
	then
		echo " Produtos"
	else
		echo " Produto "$prod
	fi
	echo ""
}

maestroInstall()
{
	if [ ! -d $HOME/code/maestro ]
	then
		echo "Deseja installar o Maestro? [y/n] "
		read maestroInstall
		if [ $maestroInstall = "y" ]
		then
			clear
			header
			source $HOME/.deploy/repo/maestro/.config
			source $HOME/.deploy/src/install.sh
		elif [ $maestroInstall != "n" ]
		then
			clear
			header
			maestroInstall
		fi
	fi	
}

menuProd(){

	clear

	header
	
	echo ""
	echo "Escolha um produto: "
	echo ""
	echo " [a] InfinityPay"
	echo " [b] B4U"

	echo ""
	read option

	case $option in
		"a")
			prod=InfinityPay
			install
			;;
		* )
			echo "Opção inválida"
			echo ""
			sleep 1
			menuProd
			;;
	esac
}

install()
{
	for entry in $HOME/.deploy/repo/$prod/*
	do
		configPath=$entry
	 	source $configPath/.config
	 	source ~/.deploy/src/install.sh

	done
}