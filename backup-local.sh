#!/bin/bash
# ------------------------------------------------------------------
# Copyright (c) 2019-08-04 Bruno Emer <emerbruno@gmail.com>
#
# Backup source, data and database from php postgres application
#
# ------------------------------------------------------------------

PROGNAME=`/usr/bin/basename $0`

print_help() {
    echo $PROGNAME
    echo ""
    echo "Backup of local php and pg"
    echo ""
    echo "Options:"
    echo "--pg_host - Postgres host"
    echo "--pg_username - Postgres username"
    echo "--pg_password - Postgres password"
    echo "--pg_db - Postgres database"
    echo "--dirs - Directories to backup, space separator"
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
        --pg_host)
            pg_host=$2
            shift
            shift
            ;;
        --pg_username)
            pg_username=$2
            shift
            shift
            ;;
        --pg_password)
            pg_password=$2
            shift
            shift
            ;;
        --pg_db)
            pg_db=$2
            shift
            shift
            ;;
        --dirs)
            bkp_dirs=$2
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

if [ -z $pg_db ]; then
        echo "pg_db option is required"
        echo ""
        print_help
        exit
fi

pg_host=${pg_host:-127.0.0.1}
pg_username=${pg_username:-postgres}
pg_password=${pg_password:-''}
pg_db=${pg_db:-postgres}
bkp_dirs=${bkp_dirs:-''}

dir=/tmp/backup
pg_file=backup-`date +%Y%m%d-%H%M%S`.sql

rm -f $dir/*.tar.gz

mkdir -p $dir/db

echo "Dumping db $pg_db to $pg_file ..."
PGPASSWORD="$pg_password" pg_dump -h $pg_host -U $pg_username $pg_db > $dir/db/$pg_file

tar_file=backup-`date +%Y%m%d-%H%M%S`.tar.gz
echo "Compacting $tar_file from dir $dir/db/ and $bkp_dirs ..."
tar -zcf $dir/$tar_file $dir/db/ $bkp_dirs

echo "Removing temp files $dir/db/ ..."
rm -rf $dir/db/

