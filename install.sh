if [ ! -d $HOME/code ]
then
	echo ""
	echo "Creating "$HOME"/code"
	mkdir $HOME/code
fi

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

cd $HOME/code


# MAESTRO	
source $HOME/.deploy/install/maestro.sh

# GLOBAL
if [ ! -d $HOME/code/global ]
then
	echo ""
	echo "Creating "$HOME"/code/global"
	mkdir $HOME/code/global
fi

# L1_AUTH
source $HOME/.deploy/install/l1_auth.sh

# L1_BANKSLIP
source $HOME/.deploy/install/l1_bankslip.sh

# L1_COMPANIES
source $HOME/.deploy/install/l1_companies.sh

# L1_CUSTOMERS
source $HOME/.deploy/install/l1_customers.sh

# L1_LOGS
source $HOME/.deploy/install/l1_logs.sh

# L1_PRODUCTS
source $HOME/.deploy/install/l1_products.sh

# L1_SUPPLIES
source $HOME/.deploy/install/l1_supplies.sh