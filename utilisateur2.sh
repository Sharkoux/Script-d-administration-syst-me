#!/bin/bash 
echo "Utilisateur:"
read Utilisateur

grep -w ^$Utilisateur /etc/passwd > /dev/null;

if [ $? = 0 ]
then
	echo "Cet utilisateur existe déjà."
	exit 0
else 
        
      	useradd -m -d  /home/$Utilisateur -s /bin/bash $Utilisateur 
	mkdir  /home/$Utilisateur/Personnel
	echo "$Utilisateur ajouté!"
	echo "Vous pouvez choisir le mot de passe: "
	passwd $Utilisateur
	echo "Mot de passe ajouté."
	echo "Dans quel groupe ajouter cet utilisateur? "
	read Group
	grep -w $Group  /etc/group > /dev/null;
	if [ $? = 0 ]
	then 
		echo "Ce groupe existe déjà, $Utilisateur y est ajouté."
		adduser $Utilisateur $Group
		exit 0
	else 
		groupadd $Group
		adduser $Utilisateur $Group
		echo "Le compte est créé."
	fi
	exit 0
fi 

