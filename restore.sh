#!/bin/bash

pod="pod"
pod_pg="postgresql"
file_pg="backup.sql"
project=default
pg_db_name=moodle

oc rsync moodle/db/ $pod_pg:/opt/app-root/src -n $project
#oc rsh -n $project $pod_pg /bin/sh -i -c "psql -f $file_pg $pg_db_name"

#oc exec $pod_pg -n $project -it -- bash
#psql moodle -c "select 'drop table if exists \"' || tablename || '\" cascade;' from pg_tables where schemaname='public';" > /tmp/drop.tmp.sql
#psql -f /tmp/drop.tmp.sql moodle
#psql -f backup.sql moodle

oc rsync moodle/etc/ $pod:/opt/app-root/etc/ -n $project

