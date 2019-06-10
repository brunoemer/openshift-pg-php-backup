#!/bin/bash
# ------------------------------------------------------------------
# Copyright (c) 2019-04-06 Bruno Emer <emerbruno@gmail.com>
#
# Backup source, data and database from pods in openshift
#
# ------------------------------------------------------------------

PROGNAME=`/usr/bin/basename $0`

print_help() {
    echo $PROGNAME
    echo ""
    echo "Backup of openshift pods"
    echo ""
    echo "Options:"
    echo "--namespace - Namespace of openshift, default is 'default'"
    echo "--dc - Deployment config name of php pod with data and source (required)"
    echo "--dcpg - Deployment config name of database pod"
    echo ""
}

if [ $# -lt 1 ]; then
    print_help
    exit
fi

while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit
            ;;
        -h)
            print_help
            exit
            ;;
        --namespace)
            project=$2
            shift
            shift
            ;;
        --dc)
            dc=$2
            shift
            shift
            ;;
        --dcpg)
            dc_pg=$2
            shift
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit
            ;;
    esac
done

if [ -z $dc ]; then
        echo "dc option is required"
        echo ""
        print_help
        exit
fi

project=${project:-default}
dc_pg=${dc_pg:-postgresql-nfs}

dir=/tmp/oc_backup
pg_db_name=moodle
pg_file=backup-`date +%Y%m%d-%H%M%S`.sql

rm -f $dir/*.tar.gz

echo "Searching for $dc pods ..."
pod=`oc get pods --show-all=false -n $project --selector app=$dc --no-headers=true |awk '{print $1}'`
if [ -n "$pod" ]; then
	echo "Found $pod"
else
	exit
fi

mkdir -p $dir/data

if [ -n "$dc_pg" ]; then

	echo "Searching for $dc_pg postgres pods ..."
	pod_pg=`oc get pods --show-all=false -n $project --selector name=$dc_pg --no-headers=true |awk '{print $1}'`
	if [ -n "$pod_pg" ]; then
		echo "Found $pod_pg"

		mkdir -p $dir/data/db/

		echo "Dumping db $pg_db_name to $pg_file ..."
		oc rsh -n $project $pod_pg /bin/sh -i -c "pg_dump $pg_db_name > $pg_file"

		oc rsync -q $pod_pg:/opt/app-root/src/ $dir/data/db/ -n $project
	fi
fi

echo "Copying files from $pod ..."
oc rsync -q $pod:/opt/app-root/ $dir/data/ -n $project

tar_file=$dc-`date +%Y%m%d-%H%M%S`.tar.gz
echo "Compacting $tar_file from dir $dir/data/ ..."
tar -zcf $dir/$tar_file $dir/data/

echo "Removing temp files $dir/data/ ..."
rm -rf $dir/data/

