#!/bin/sh
check=`echo $1 | tail -c 5`
#echo $1 >> /home/dorggie/ftp.log
if [ $check == ".exe" ]
then
		logger -p local5.info "connect"
		log=`cat /var/log/ftpd.log | tail -1 | sed 's/connect//g'`
		owner=`ls -la $1 | awk '{print $3}'`
		echo $log$1 violate file detected. Uploaded by $owner. >> /home/ftp/public/pureftpd.viofile
		mv $1 /home/ftp/hidden/.exe/
    ls -la /home/ftp/hidden/.exe/  >> /home/dorggie/ftp.log
fi
