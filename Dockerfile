FROM ubuntu
# DDBMS=<drizzle|mysql|pgsql|sapdb>
ENV DDBMS=pgsql
ENV PACKAGES_DEPENDENCIES='build-essential cmake postgresql libpq-dev postgresql-server-dev-9.3'
RUN apt-get update && apt-get install -y $PACKAGES_DEPENDENCIES
COPY . osdldbt-dbt2
WORKDIR osdldbt-dbt2
RUN cmake -DDBMS=$DDBMS -DDESTDIR=/usr/local
RUN make
RUN make install
RUN make -C storedproc/pgsql/c
RUN make -C storedproc/pgsql/c install
