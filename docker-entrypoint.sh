#!/bin/bash
set -x -e
PATH=$PATH:/usr/lib/postgresql/9.3/bin/
source /osdldbt-dbt2/examples/dbt2_profile
: ${DBT2PGDATA:=/var/lib/postgresql/local/dbt2/pgdata}
: ${PG_CONF:=${DBT2PGDATA}/postgresql.conf}
: ${PG_PID:=${DBT2PGDATA}/postmaster.pid}
: ${PG_LOG:=${HOME}/dbt2.log}
rm -f ${PG_PID}

: ${PG_PARAMS:="\
checkpoint_segments \
checkpoint_timeout \
checkpoint_completion_target \
autovacuum \
wal_buffers \
shared_buffers \
effective_cache_size \
log_checkpoints \
log_line_prefix \
bgwriter_lru_multiplier \
bgwriter_lru_maxpages \
synchronous_commit"}

# Recommended by Maxime
: ${checkpoint_completion_target:=0.9}
: ${autovacuum:=false}
: ${wal_buffers:=16MB}
: ${log_checkpoints:=true}
: ${log_line_prefix:="'%m '"}
: ${bgwriter_lru_multiplier:=2.0}

# TODO
: ${checkpoint_segments:=128}
: ${checkpoint_timeout:=10min}
: ${shared_buffers:=128MB}
: ${effective_cache_size:=128MB}
: ${bgwriter_lru_maxpages:=100}
: ${synchronous_commit:=on}

: ${ANON:=0}
: ${ANON_AT:=0}

configure_one()
{
    name=$1
    eval value=$`echo $1`
    sed -i "s/.*${name} = .*/${name} = ${value} # MODIFIED BY SED/" ${PG_CONF}
}

configure_all()
{
    for p in ${PG_PARAMS}; do configure_one ${p}; done
}

init()
{
    dbt2-pgsql-build-db -w ${WAREHOUSES}
    configure_all
    grep '# MODIFIED BY SED' ${PG_CONF}
}

run()
{
    (sleep ${ANON_AT}; /anon ${ANON} 0) &
    dbt2-run-workload -a pgsql -d ${DURATION} -w ${WAREHOUSES} -o /tmp/result -c 10 -s ${SLEEPY}
}

report()
{
    dbt2-generate-report -i /tmp/result
    cp ${PG_CONF} /tmp/result/db/
}

case $1 in
    init) init;;
    run) run;;
    report) report;;
    *) init; run; report;;
esac
