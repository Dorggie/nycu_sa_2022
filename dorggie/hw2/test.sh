#!/bin/sh

#test=`cat generated.hw2 | jq '.files | .[].type'`
#a=0
#for i in $test; do
#		data = `cat generated.hw2 | jq '.files | .['$a'].data'`
#		echo ${data:1:-1}
#		a=$(( $a+1 ))
#done

a="123"
echo $a
a=$a"\n456"
echo $a

echo finish
