#!/bin/bash


project=bruno
dc="tutora"
dc_pg="postgresql"

dir=/tmp/oc_backup
pg_db_name=moodle
pg_file=backup-`date +%Y%m%d-%H%M%S`.sql

echo "Searching for $dc pods ..."
pod=`oc get pods --show-all=false -n $project --selector app=$dc --no-headers=true |awk '{print $1}'`
if [ -n "$pod" ]; then
	echo "Found $pod"
fi

mkdir -p $dir/data

if [ -n "$dc_pg" ]; then

	echo "Searching for $dc_pg postgres pods ..."
	pod_pg=`oc get pods --show-all=false -n $project --selector name=$dc_pg --no-headers=true |awk '{print $1}'`
	if [ -n "$pod" ]; then
		echo "Found $pod_pg"
	fi

	mkdir -p $dir/data/db/

	echo "Dumping db $pg_db_name to $pg_file ..."
	oc rsh -n $project $pod_pg /bin/sh -i -c "pg_dump $pg_db_name > $pg_file"

	oc rsync -q $pod_pg:/opt/app-root/src/ $dir/data/db/ -n $project
fi

echo "Copying files from $pod ..."
oc rsync -q $pod:/opt/app-root/ $dir/data/ -n $project

tar_file=$dc-`date +%Y%m%d-%H%M%S`.tar.gz
echo "Compacting $tar_file from dir $dir/data/ ..."
tar -zcf $dir/$tar_file $dir/data/

echo "Removing temp files $dir/data/ ..."
#rm -rf $dir/data/

