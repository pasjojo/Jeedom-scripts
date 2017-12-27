#!/bin/bash
DATE=$(date +"%Y-%m-%d")
BoxToClone=Jeedom
SdImgSize=16012804096
FileName=SD-Backup_$BoxToClone\_$DATE.img.gz
File=/mnt/nfsbackup/SD/$FileName

# Copie des fichier Mysql à froid
/etc/init.d/mysql stop
rsync -vra --progress --delete /var/lib/mysql /var/lib/mysql_cold/
/etc/init.d/mysql start

#sans compression : sudo dd if=/dev/mmcblk0 bs=4M of=$File && sync
sudo dd if=/dev/mmcblk0 bs=4096 conv=notrunc,noerror | sudo gzip -1 -| sudo dd of=$File && sync


FileStat=$(wc -c "$File" | cut -f 1 -d ' ')


if [ $? -eq 0 ]; then
        if [ $FileStat -ge $SdImgSize ]; then
                Objet="($DATE) SD Backup $BoxToClone sur NFS: ERREUR"
                Message="Taille du fichier $FileName incorrecte"
        else
                #taille OK
                Objet="($DATE) SD Backup $BoxToClone sur NFS : OK"
                Message="Clonage OK"
        fi
else
        if [ -e $File ]; then
                sudo rm $File
        fi
        Objet="($DATE) SD Backup $BoxToClone sur NFS : ECHEC"
        Message="Echec du Clonage : fichier inexistant."
fi

TEXTE="$Objet - $Message"

# echo "$Message" | mail -s "$Objet"  joel@jopa.fr
curl -s -i \
        -H "Accept: application/json" \
        -H "Content-Type:application/json" \
        -X POST --data '{"text":"'"$TEXTE"'"}' "https://hooks.slack.com/services/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" \
        -o /dev/null -s

