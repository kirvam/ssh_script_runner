#!/usr/bin/sh
# NAME: yum_cheker.sh
# DATE: 09/24/2021
# AUTH: PMH
# DESC: Script to check for OMI & and replace if possible???
#
LOG="fRiday_omi_check.log"
echo "--- starting log: $LOG ---" > $LOG
HOSTNAME=$(hostname)
HOSTNAME_IP=$(hostname -i)
IP=$(ip addr sho | grep -iE '(eth0|ens)')
#FIND_THIS="falcon-sensor"
FIND_THIS="omi"
UBUNTU=$(cat /etc/os-release | grep -E '(NAME\=\"Ubuntu\")')
CENTOS=$(cat /etc/centos-release | grep -i centos)

echo $UBUNTU >> $LOG
echo $CENTOS >> $LOG

#YUM_CMD=$(yum info $FIND_THIS | grep -i name| grep -i $FIND_THIS)
#APT_CMD=$(apt list --installed $FIND_THIS)

if [[ ! $UBUNTU ]];
then 
  echo " "
  YUM_CMD=$(yum info $FIND_THIS | grep -i name| grep -i $FIND_THIS)
  echo "YUM_CMD is looking for ^$FIND_THIS^ ..."
  echo "Result of search: ^$YUM_CMD^"
  echo "Result of search: ^$YUM_CMD^" >> $LOG
  echo " "
  OUT=$YUM_CMD
else
  echo " "
  APT_CMD=$(apt list --installed $FIND_THIS| grep -i omi)
  echo "APT_CMD is looking for ^$FIND_THIS^ ..."
  echo "Result of search: ^$APT_CMD^"
  echo "Result of search: ^$APT_CMD^" >> $LOG
  echo " "
  OUT=$APT_CMD
fi

echo $OUT >> $LOG

if [[ $OUT = "" ]]
then
  echo "###EC##N# $HOSTNAME_IP, $HOSTNAME, $FIND_THIS NOT found!"
  echo "###EC##N# $HOSTNAME_IP, $HOSTNAME, $FIND_THIS NOT found!" >> $LOG
else
  echo "###EC##Y# $HOSTNAME_IP, $HOSTNAME, $FIND_THIS installed."
  echo "###EC##Y# $HOSTNAME_IP, $HOSTNAME, $FIND_THIS installed." >> $LOG

fi
echo " "
echo "--- finished ---" >> $LOG
