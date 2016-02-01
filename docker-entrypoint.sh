#!/bin/bash
set -x -e
PATH=$PATH:/usr/lib/postgresql/9.3/bin/
source /osdldbt-dbt2/examples/dbt2_profile
init()
{
    dbt2-pgsql-build-db -w ${WAREHOUSES:1}
}

run()
{
    dbt2-run-workload -a pgsql -d 300 -w ${WAREHOUSES:1} -o /tmp/result -c 10
}

case $1 in
    init) init;;
    run) run;;
    *) init; run;;
esac
