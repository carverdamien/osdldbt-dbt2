#!/bin/bash
set -x -e
PATH=$PATH:/usr/lib/postgresql/9.3/bin/
source /osdldbt-dbt2/examples/dbt2_profile
rm -f /var/lib/postgresql/local/dbt2/pgdata/postmaster.pid
init()
{
    dbt2-pgsql-build-db -w ${WAREHOUSES}
}

run()
{
    dbt2-run-workload -a pgsql -d ${DURATION} -w ${WAREHOUSES} -o /tmp/result -c 10
    sleep ${SLEEP}
}

report()
{
    dbt2-generate-report -i /tmp/result
}

case $1 in
    init) init;;
    run) run;;
    report) report;;
    *) init; run; report;;
esac
