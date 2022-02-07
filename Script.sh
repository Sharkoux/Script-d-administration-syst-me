#!/bin/bash 

echo 'Ce script permet l'installation d'un site e commerce wordpress'
echo -n ' Voulez vous continuer? Y/N '
read -r debut

if [ "$debut" = "Y" ]; then 
	echo 'Bienvenue dans cet outil d'installation.'
	sleep 1

else
	echo 'Au revoir!'
	exit 0

fi

apt-get install curl php-mysql php libapache2-mod-php && apt-get install mariadb-server 
echo 'Installation de wp-cli'
mkdir /home/toto/public_html
cd /home/toto/public_html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
mkdir ~/bin
mv wp-cli.phar ~/bin/wp
chmod +x ~/bin/wp
(cat << EOF > ~/.bashrc
export PATH="~/bin:\$PATH"
EOF)
sleep 0

echo 'J'ai besoin de quelques informations : '
echo 'Comment voulez vous nommer l'administrateur de la base de donnée ? '
read -r admin
echo 'Quel mot de passe attribuer à l'administrateur ? '
read -r passadmin
echo 'Quel nom de domaine attribuer à votre site ?'
read -r monsite
echo 'Comment voulez vous nommer votre site ? '
read -r titre
echo 'Comment voulez vous nommer l'administrateur de votre site ? '
read -r adminsite
echo 'Quel mot de passe attribuer à l'administrateur du site ? '
read -r passadminsite
echo 'Quel email associer à votre administrateur ? '
read -r email1

echo 'Installation de wordpress : '
source ~/.bashrc
wp core download --allow-root
wp core config --dbname="Wp-Base" --dbuser="$admin" --dbprefix="monwp_" --dbpass="$passadmin" -allow-root
wp db create --allow-root 
wp core install --url="$monsite" --title="$titre" --admin_user="$adminsite" --admin_password="$passadminsite" --admin_email="$email1" --allow-root
wp core language list
wp core language install --activate fr_FR

wp rewrite structure '/%postname%'
sleep 5

echo 'Voulez vous installer un thème particulier ? Y/N '
read -r reponse

if [ "$reponse" = "Y" ]
then
	variable1=$(wp theme list)
	echo "$variable1 "
	echo "Quel thème voulez vous installer ? "
	read -r theme
	wp theme search $theme
	while [ $? -ne 0 ]
	do
		echo "Ce thème n'existe pas ou il y a une erreur de synthaxe. "
		read -r theme
		wp theme search $theme
	done
	wp theme install $theme
	wp theme activate $theme
	echo "$theme bien installé."
	sleep 0
else 
	echo "Passons à la suite!"
	sleep 0
fi

echo "Voulez vous installer une ou des extensions ? Y/N "
read -r exten

if [ "$exten" = "Y" ]
then
	echo "Voulez vous installer le pack de base d'extensions E-Commerce ? Y/N "
	read exten2
	if [ "$exten2" = "Y" ]
	then 
		wp plugin install woocommerce
		wp plugin activate woocommerce
		wp plugin install wordpress-seo
		wp plugin activate wordpress-seo
		wp plugin install jetpack
		wp plugin activate jetpack
		wp plugin install akismet
		wp plugin activate akismet
		wp plugin install wp-cache
		wp plugin activate wp-cache
		wp plugin install mailpoet
		wp plugin activate mailpoet
		sleep 0
	else 
		variable2=$(wp plugin list)
		echo "$variable2 "
		echo "Quel plugin voulez vous installer ? "
		read plugin1
		wp plugin search $plugin1
		while [ $? -ne 0 ] 
		do 					
			echo "Ce plugin n'existe pas ou il y a une erreur de synthaxe. "
			read plugin1
			wp plugin search $plugin1
		done 
		wp plugin install $plugin1
		wp plugin activate $plugin1
		
	fi 
else
	echo " Fin de l'installation de base. "
	sleep 0
fi


echo "Voulez vous créé un script de mise à jour du site? [Y/N] "
read -r ajour
if [ "$ajour" = "Y" ]
then 
	cd /home/
	touch maj.sh
	echo "wp core update
	wp core update-db
	wp plugin update --all --dry-run
	wp plugin update --all
	wp theme update --all --dry-run
	wp theme update --all " >> maj.sh
	chmod +x maj.sh
	00 15 * * * root /home/maj.sh
	sleep 0
else
	echo "Bien, continuons. "
fi

echo "Voulez vous créé un script de sauvegarde de votre base de donnée ? [Y/N] "
read -r save
if [ "$save" = "Y" ]
then
	cd /home/
	touch save.sh
	echo "wp db export backup.sql " >> save.sh
	chmod +x save.sh
	00 13 * * * root /home/maj.sh
	sleep 0
else
	echo "Okay, continuons."
	sleep 0
fi

echo "Bravo, l'installation est bien terminée, votre site est normalement en ligne, plus qu'à le sécurisé (mais cela se fera dans un autre script). "
