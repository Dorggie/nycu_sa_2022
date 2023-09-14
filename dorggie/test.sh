#!/bin/sh
var="/usr/home/ftp/public/a.exe"
check=`echo $var | tail -c 5`

if [ $check == ".exe" ]
then
        echo yes
else
        echo no
fi

