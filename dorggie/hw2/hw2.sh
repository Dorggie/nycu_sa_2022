#!/bin/sh

help_stderr(){
		echo "hw2.sh -i INPUT -o OUTPUT [-c csv|tsv] [-j]" >&2
		echo "" >&2
		echo "Available Options:" >&2
		echo "" >&2
		echo "-i: Input file to be decoded" >&2
		echo "-o: Output directory" >&2
		echo "-c csv|tsv: Output files.[ct]sv" >&2
		echo "-j: Output info.json" >&2
}
output_file_flag=false
output_json_flag=false
while getopts ':i:o:c:j' OPT; do
		case $OPT in
				i) input=$OPTARG ;;
				o) output_directory=$OPTARG ;;
				c) output_file=$OPTARG ;;
				j) output_json_flag=true ;;
				*) help_stderr
					 exit 1 ;;
		esac
done

if [ -z "$input" ] || [ -z "$output_directory" ]; then
		help_stderr
		exit 1
fi

if [ ! -z "$output_file" ]; then
		if [ $output_file == "csv" ] || [ $output_file == "tsv" ]; then
				output_file_flag=true
		else
				help_stderr
				exit 1
		fi
fi
# output directory
mkdir -p $output_directory

# csv/tsv file
if $output_file_flag; then
		if [ $output_file == "csv" ]; then
				touch $output_directory/files.csv
				echo filename,size,md5,sha1 >> $output_directory/files.csv
		elif [ $output_file == "tsv" ]; then
				touch $output_directory/files.tsv
				printf 'filename\tsize\tmd5\tsha1\n' >> $output_directory/files.tsv
		fi
fi

# one file
files=`cat $input | jq '.files | .[].type'`
count=0
checksum=0
for i in $files; do
		name=`cat $input | jq '.files | .['$count'].name' | sed 's/"//g'`
		mkdir -p $output_directory/$name
		rmdir $output_directory/$name
		touch $output_directory/$name
		`cat $input | jq '.files | .['$count'].data' | sed 's/"//g' | base64 --decode > $output_directory/$name`

		size=`ls -la $output_directory/$name | awk '{print $5}'`
		md5=`cat $input | jq '.files | .['$count'].hash | .md5' | sed 's/"//g'`
		sha1=`cat $input | jq '.files | .['$count'].hash | ."sha-1"' | sed 's/"//g'`
		
		count_md5=`cat $input | jq '.files | .['$count'].data' | sed 's/"//g' | base64 --decode | md5sum`
		count_sha1=`cat $input | jq '.files | .['$count'].data' | sed 's/"//g' | base64 --decode | sha1sum` 
		if [ $md5 != $count_md5 ] || [ $sha1 != $count_sha1 ]; then
				checksum=$(( $checksum+1 ))
		fi

		if $output_file_flag; then	
				if [ $output_file == "csv" ]; then
						echo $name,$size,$md5,$sha1 >> $output_directory/files.csv
				elif [ $output_file == "tsv" ]; then
						printf "%s\t%s\t%s\t%s\n" $name $size $md5 $sha1 >> $output_directory/files.tsv
				fi
		fi

		count=$(( $count+1 ))
done

if $output_json_flag; then
		time=`cat $input | jq .date`
		date=`date -j -f "%s" $time '+%Y-%m-%dT%H:%M:%S+08:00'`
		filename=`cat $input | jq .name | sed 's/"//g'`
		author=`cat $input | jq .author | sed 's/"//g'`
		touch $output_directory/info.json
		jq -n --arg name $filename --arg author $author --arg date $date '$ARGS.named' > $output_directory/info.json
fi

#echo checksum $checksum
exit $checksum
