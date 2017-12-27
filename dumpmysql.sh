#!/bin/bash

DATE=`date +%y%m%d-%H%M`
echo $DATE > /usb/MYSAUVE/mysql-sauve.log
mysqldump --defaults-file=/etc/mysql/debian.cnf -a -c -A --events > /usb/MYSAUVE/mysql-$DATE-ALL.sql 2>> /usb/MYSAUVE/mysql-sauve.log

for BASE in jeedom;
do
    mysqldump --defaults-file=/etc/mysql/debian.cnf -a -c $BASE > /usb/MYSAUVE/mysql-$DATE-$BASE.sql 2>> /usb/MYSAUVE/mysql-sauve.log
done


# Compression des dumps
for SAUVEGARDE in `ls /usb/MYSAUVE/*.sql` ;
do
  echo "Compression de la sauvegarde : $SAUVEGARDE" >> /usb/MYSAUVE/mysql-sauve.log
  gzip "$SAUVEGARDE"
done



# Suppression des anciens logs de snapshots
COMPTEUR=0
MAXJOUR=10
for SAUVEGARDE in `ls -r /usb/MYSAUVE/*-ALL.sql.gz` ;
do
        let $[COMPTEUR+=1]
        if [ $COMPTEUR -gt $MAXJOUR ]; then
           echo "Suppression de l'ancienne sauvegarde : $SAUVEGARDE" >>/usb/MYSAUVE/mysql-sauve.log
           rm -fr "$SAUVEGARDE"
        fi
done

for BASE in jeedom;
do 
   COMPTEUR=0
   MAXJOUR=10
   for SAUVEGARDE in `ls -r /usb/MYSAUVE/*-$BASE.sql.gz` ;
   do
        let $[COMPTEUR+=1]
        if [ $COMPTEUR -gt $MAXJOUR ]; then
           echo "Suppression de l'ancienne sauvegarde : $SAUVEGARDE" >>/usb/MYSAUVE/mysql-sauve.log
           rm -fr "$SAUVEGARDE"
        fi
   done
done


COMPTEUR=0
MAXJOUR=5
for SAUVEGARDE in `ls -r /usb/MYSAUVE/*.log` ;
do
        let $[COMPTEUR+=1]
        if [ $COMPTEUR -gt $MAXJOUR ]; then
           echo "Suppression des anciens logs  : $SAUVEGARDE" >>/usb/MYSAUVE/mysql-sauve.log
           rm -fr "$SAUVEGARDE"
        fi
done


cp /usb/MYSAUVE/mysql-sauve.log /usb/MYSAUVE/mysql-$DATE.log
