#!/bin/bash
 
domain=$1
ip=$2
 
aide () {
	echo "2 parameters are needed :"
	echo "Domain"
	echo "Container IP "
	echo ""
        echo "Check Apache conf..."
	apache2ctl -t
	exit
}
 
# On vérifie que l'utilisateur a bien entré 2 paramètres
if [[ $# != 2 ]]
	then
		aide
		exit
fi
 
echo "Is everything ok  ? [y/n] :"
echo "    - Domain : $domain"
echo "    - Container's IP : 192.168.1.${ip}"
 
read -p "Create reverse proxy ? y/n" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
 
    cat <<EOF>> /etc/apache2/sites-available/${domain}.conf
<VirtualHost *:80>
   ServerName ${domain}
   ServerAlias www.${domain}
 
   ProxyRequests Off
   ProxyPreserveHost On
 
   <Proxy *>
         Order allow,deny
         Allow from all
   </Proxy>
 
   ProxyVia on
   ProxyPreserveHost on
 
   ProxyPass / http://192.168.1.${ip}/
   ProxyPassReverse / http://192.168.1.${ip}/
</VirtualHost>
EOF
 
    cd /etc/apache2/sites-available/
    a2ensite ${domain}.conf
 
    apache2ctl -t
 
    if [[ $? -ne 0 ]] ; then echo -e "Probleme de syntaxe, abandon"; exit; fi
 
    echo "Reverse proxy ${domain} has been created"
 
    read -p "Reboot apache ? y/n" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        service apache2 reload
        if [[ $? -ne 0 ]] ; then echo -e "Apache didn't reboot, abandon"; exit; fi
        echo "Reverse proxy ${domain} is active"
    fi
 
fi
exit
