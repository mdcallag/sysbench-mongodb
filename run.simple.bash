#!/bin/bash

# simple script to run against running MongoDB/TokuMX server localhost:(default port)

# enable passing different config files

#if [ ! $1 ];
#then
#    FILE="config.bash"
#else
#    FILE=$1
#fi

FILE="config.bash"

if [ -f $FILE ];
then
   echo "Loading config from $FILE....."
   source $FILE
else
   echo "Unable to read config $FILE"
   exit 1
fi

CLASSPATH=mongo-java-driver-2.13.1.jar
javac -cp $CLASSPATH:$PWD/src src/jmongosysbenchload.java
javac -cp $CLASSPATH:$PWD/src src/jmongosysbenchexecute.java

JAVA=$JAVAB

# load the data

if [[ $DOLOAD = "yes" ]]; then
    echo Do load at $( date )
    export LOG_NAME=mongoSysbenchLoad-${NUM_COLLECTIONS}-${NUM_DOCUMENTS_PER_COLLECTION}-${NUM_LOADER_THREADS}.txt
    export BENCHMARK_TSV=${LOG_NAME}.tsv
 
    rm -f $LOG_NAME
    rm -f $BENCHMARK_TSV

# python mstat.py --loops 1000000 --interval 10 >& o.mstat.l &
# mid=$!
iostat -kx 2 >& l.io &
lpid=$!
vmstat 2 >& l.vm &
vpid=$!

    T="$(date +%s)"
    $JAVA -cp $CLASSPATH:$PWD/src jmongosysbenchload $NUM_COLLECTIONS $DB_NAME $NUM_LOADER_THREADS $NUM_DOCUMENTS_PER_COLLECTION $NUM_DOCUMENTS_PER_INSERT $NUM_INSERTS_PER_FEEDBACK $NUM_SECONDS_PER_FEEDBACK $BENCHMARK_TSV $MONGO_COMPRESSION $MONGO_BASEMENT $WRITE_CONCERN $MONGO_SERVER $MONGO_PORT "$USERNAME" "$PASSWORD" 2>&1 | tee -a $LOG_NAME
    echo "" | tee -a $LOG_NAME
    T="$(($(date +%s)-T))"
    printf "`date` | sysbench loader duration = %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" | tee -a $LOG_NAME

# kill $mid
kill $vpid
kill $lpid

echo "db.serverStatus()" | ${MONGO_DIR}/bin/mongo > l.status
du -hs ${MONGO_DIR}/data >> $LOG_NAME
du -hs --apparent-size ${MONGO_DIR}/data >> $LOG_NAME
ps aux | grep mongod | grep -v grep >> $LOG_NAME
tail -3 $LOG_NAME

fi


# execute the benchmark

if [[ $DOQUERY = "yes" ]]; then
    echo Do query at $( date )
    export LOG_NAME=mongoSysbenchExecute-${NUM_COLLECTIONS}-${NUM_DOCUMENTS_PER_COLLECTION}-${NUM_WRITER_THREADS}.txt
    export BENCHMARK_TSV=${LOG_NAME}.tsv
 
    rm -f $LOG_NAME
    rm -f $BENCHMARK_TSV

# python mstat.py --loops 1000000 --interval 10 >& o.mstat.r &
# mid=$!
iostat -kx 2 >& r.io &
lpid=$!
vmstat 2 >& r.vm &
vpid=$!

    T="$(date +%s)"
    $JAVA -cp $CLASSPATH:$PWD/src jmongosysbenchexecute $NUM_COLLECTIONS $DB_NAME $NUM_WRITER_THREADS $NUM_DOCUMENTS_PER_COLLECTION $NUM_SECONDS_PER_FEEDBACK $BENCHMARK_TSV $SYSBENCH_AUTO_COMMIT $RUN_TIME_SECONDS $SYSBENCH_RANGE_SIZE $SYSBENCH_POINT_SELECTS $SYSBENCH_SIMPLE_RANGES $SYSBENCH_SUM_RANGES $SYSBENCH_ORDER_RANGES $SYSBENCH_DISTINCT_RANGES $SYSBENCH_INDEX_UPDATES $SYSBENCH_NON_INDEX_UPDATES $SYSBENCH_INSERTS $WRITE_CONCERN $MAX_TPS $MONGO_SERVER $MONGO_PORT $SEED "$USERNAME" "$PASSWORD" 2>&1 | tee -a $LOG_NAME
    echo "" | tee -a $LOG_NAME
    T="$(($(date +%s)-T))"
    printf "`date` | sysbench benchmark duration = %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))" | tee -a $LOG_NAME

# kill $mid
kill $vpid
kill $lpid

echo "db.serverStatus()" | ${MONGO_DIR}/bin/mongo > r.status
du -hs ${MONGO_DIR}/data >> $LOG_NAME
du -hs --apparent-size ${MONGO_DIR}/data >> $LOG_NAME
ps aux | grep mongod | grep -v grep >> $LOG_NAME
tail -3 $LOG_NAME

fi

