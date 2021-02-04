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
	clearVariables
	if [ ! -d $HOME/code/maestro ]
	then
		echo "Deseja installar o Maestro? [Y/n] "
		read maestroInstall
		if [ $maestroInstall = "Y" ]
		then
			clear
			header
			configPath=$HOME/.deploy/repo/maestro
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

maestroUninstall()
{
	clearVariables
	unset maestrohost
	unset maestrotoken
	if [ -d $HOME/code/maestro ]
	then
		echo "Deseja desinstallar o Maestro? [Y/n] "
		read maestroUninstall
		if [ $maestroUninstall = "Y" ]
		then
			clear
			header
			configPath=$HOME/.deploy/repo/maestro/
			source $HOME/.deploy/repo/maestro/.config
			source $HOME/.deploy/src/uninstall.sh
		elif [ $maestroUninstall != "n" ]
		then
			clear
			header
			maestroUninstall
		else
			menuProd
		fi
	fi
}

options()
{
	clear

	header

	echo ""
	echo "O que você deseja fazer?"

	echo ""
	echo " [a] Instalar"
	echo " [b] Deploy Local"
	echo " [c] Deploy Produção"
	echo " [d] Desinstalar"

	echo ""
	read o

	case $o in
		"a")
			install
			;;
		"b")
			echo "Essa opção ainda não implementada"
			sleep 1
			;;
		"c")
			echo "Essa opção ainda não implementada"
			sleep 1
			;;
		"d")
			echo "Tem certeza que deseja desinstalar todos os repositórios desse projeto? [Y/n]"
			echo ""
			read confirm
			if [ $confirm = "Y" ]
			then
				uninstall
			elif [ $confirm = "n" ]
			then
				echo ""
				echo "Nenhuma ação foi realizada"
				sleep 1
			else
				echo ""
				echo "Opção inválida"
				echo ""
				sleep 1
				options
			fi
			;;
		* )
			echo ""
			echo "Opção inválida"
			echo ""
			sleep 1
			options
			;;
	esac

	menuProd
}

clearVariables()
{
	unset prod
	unset project
	unset folder
	unset option
	unset maestroOp
	unset configPath
	unset pathProj
	unset DB_DATABASE
}

menuProd(){

	clearVariables

	clear

	header
	
	echo ""
	echo "Escolha um produto: "
	echo ""
	echo " [a] InfinityPay"
	echo " [b] B4U"
	echo " [c] Suppliers"
	echo " [d] Maestro"
	echo " [e] Global"
	echo ""
	echo " [z] Sair"

	echo ""
	read option

	case $option in
		"a")
			prod=InfinityPay
			options
			;;
		"b")
			prod=B4U
			options
			;;
		"c")
			prod=Suppliers
			options
			;;
		"d")
			prod=Maestro
			clear
			header
			if [ -d $HOME/code/maestro ]
			then
				maestroUninstall
				menuProd
			else	
				maestroInstall
				menuProd
			fi
			;;
		"e")
			prod=Global
			options
			;;
		"z")
			return 1
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

uninstall()
{
	for entry in $HOME/.deploy/repo/$prod/*
	do
		configPath=$entry
	 	source $configPath/.config
	 	source ~/.deploy/src/uninstall.sh
	done

	if [ -h /var/www/html/${project} ]
	then
		echo ""
		echo "chown $USER:$GROUP /var/www/html/${project} -R"
		sudo chown $USER:$GROUP /var/www/html/${project} -R

		echo ""
		echo "Remove /var/www/html/${project}"
		sudo rm /var/www/html/${project} -rf
	fi
	if [ -d ~/code/${project} ]
	then
		rm -rf ~/code/${project}
	fi
}