#!/bin/sh

# sysstats.sh
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002 Mark Wong & Open Source Development Lab, Inc.
#
# 17 october 2002

if [ $# -lt 1 ]; then
    echo "usage: sysstats.sh --db <database> --dbname <database_name> --outdir <output_dir> --iter <iterations> -sample <sample_length>"
    echo "	<output_dir> will be created if it doesn't exist"
    exit
fi

COUNTER=0

while :
do
	case $# in
	0)
		break
		;;
	esac

	option=$1
	shift

	orig_option=$option
	case $option in
	--*)
		;;
	-*)
		option=-$option
		;;
	esac

	case $option in
	--*=*)
		optarg=`echo $option | sed -e 's/^[^=]*=//'`
		arguments="$arguments $option"
		;;
	--db | --dbname | --outdir | --iter | --sample)
		optarg=$1
		shift
		arguments="$arguments $option=$optarg"
		;;
	esac

	case $option in
	--db)
		DATABASE=$optarg
		;;
	--dbname)
		DATABASE_NAME=$optarg
		;;
	--outdir)
		OUTPUT_DIR=$optarg
		;;
	--iter)
		ITERATIONS=$optarg
		;;
	--sample)
		SAMPLE_LENGTH=$optarg
		;;
	esac
done

if [ -z $DATABASE ]; then
	echo "use --db"
	exit
fi
if [ -z $DATABASE_NAME ]; then
	echo "use --dbname"
	exit
fi
if [ -z $OUTPUT_DIR ]; then
	echo "use --outdir"
	exit
fi
if [ -z $ITERATIONS ]; then
	echo "use --iter"
	exit
fi
if [ -z $SAMPLE_LENGTH ]; then
	echo "use --sample"
	exit
fi

# create the output directory in case it doesn't exist
mkdir -p $OUTPUT_DIR

# create a readme with general information
date >> $OUTPUT_DIR/readme.txt
uname -a >> $OUTPUT_DIR/readme.txt
echo "sample length: $SAMPLE_LENGTH seconds" >> $OUTPUT_DIR/readme.txt
echo "iterations: $ITERATIONS" >> $OUTPUT_DIR/readme.txt


echo "starting system data collection"

# collect cpu data per cpu
sar -u -U ALL $SAMPLE_LENGTH $ITERATIONS >> $OUTPUT_DIR/cpu.out &

# collect network traffic data per device
sar -n DEV $SAMPLE_LENGTH $ITERATIONS >> $OUTPUT_DIR/network.out &

# collect i/o data per logical device
iostat -d -x $SAMPLE_LENGTH $ITERATIONS >> $OUTPUT_DIR/iostat.out &


# collect database statistics
echo "starting database statistics gathering"
if [ $DATABASE = "sapdb" ]; then
	sapdb/db_stats.sh DBT2 $OUTPUT_DIR $ITERATIONS $SAMPLE_LENGTH
fi


echo "data gathering complete, transforming data..."
grep all $OUTPUT_DIR/cpu.out | grep -v Average | awk '{ print NR","$4","$5","$6 }' > $OUTPUT_DIR/cpu_all.csv