#!/bin/bash

pod="pod"
pod_pg="postgresql"
file_pg="backup.sql"
project=default
pg_db_name=moodle

oc rsync moodle/db/ $pod_pg:/opt/app-root/src -n $project
#dump postgres
#echo ": psql -f $file_pg moodle"
#oc exec $pod_pg -n $project -it -- bash
oc rsh -n $project $pod_pg /bin/sh -i -c "psql -f $file_pg $pg_db_name"

oc rsync moodle/ $pod:/opt/app-root/ -n $project


