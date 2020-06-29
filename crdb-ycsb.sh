
# assume to be in Users/rslee/bin/ycsb-0.12.0

LIB=~/gitHub/crdb-ycsb
BIN=~/bin
YCSB=~/bin/ycsb-0.12.0

cd $YCSB

if [ ! -x bin/ycsb ]; then
  echo "bin/ycsb not found or exec"
  exit 1
fi

if [ ! -f jdbc-binding/conf/crdb.properties ]; then
cat > jdbc-binding/conf/crdb.properties << EOF
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://127.0.0.1:26257/ycsb?sslmode=disable
db.user=root
db.passwd=
EOF
fi


find $BIN -name "cockroach-*-amd64" | while read dir; do
  version=`echo $dir | awk -F'-' 'NF==4 {print $2} NF==5 {print $2"-"$3}'`
  echo $dir $version

  cp $dir/cockroach $BIN/.
  pkill -9 roachdemo
  pkill -9 cockroach
  rm -rf cockroach-data
  roachdemo -n 5 &
  RDPID=$!

  sleep 10
  cockroach version
cockroach sql --insecure << EOF
create database ycsb;
CREATE TABLE ycsb.usertable (
	YCSB_KEY VARCHAR(255) PRIMARY KEY,
	FIELD0 TEXT, FIELD1 TEXT,
	FIELD2 TEXT, FIELD3 TEXT,
	FIELD4 TEXT, FIELD5 TEXT,
	FIELD6 TEXT, FIELD7 TEXT,
	FIELD8 TEXT, FIELD9 TEXT
);
EOF

  for r in 5 3 1; do
    echo "num_replicas: $r" | cockroach zone set ycsb --insecure -f -

    echo "Making sure there are no ranges underreplicated"
    ranges_underreplicated=`curl -s http://localhost:26258/_status/vars | grep "^ranges_underreplicated" | grep -v ".* 0$" | wc -l`
    while [ $ranges_underreplicated -gt 0 ]; do
      echo "$ranges_underreplicated waiting for 10 sec to catch up"
      sleep 10
      ranges_underreplicated=`curl -s http://localhost:26258/_status/vars | grep "^ranges_underreplicated" | grep -v ".* 0$" | wc -l`
    done

    for w in a b c f d e; do
      if [ "$w" == "a" -o "$w" == "e" ]; then
        cockroach sql --insecure -e "truncate ycsb.usertable"
        bin/ycsb load jdbc -P workloads/workload$w -P jdbc-binding/conf/crdb.properties > $version.$r.load.$w.log
      fi
      bin/ycsb run jdbc -P workloads/workload$w -P jdbc-binding/conf/crdb.properties -p maxexecutiontime=30 -p operationcount=10000000 > $version.$r.run.$w.log
    done
  done

  kill $RDPID
  pkill -9 cockroach
  rm -rf cockroach-data
done


echo "db,scenario,workload,replica,time,read,update,rmw,insert,scan" > results.csv
find $BIN -name "cockroach-*-amd64" | while read dir; do
  version=`echo $dir | awk -F'-' 'NF==4 {print $2} NF==5 {print $2"-"$3}'`
  for r in 5 3 1; do
    for w in a b c f d e; do
      if [ "$w" == "a" -o "$w" == "e" ]; then
      grep -e "Operations" -e "RunTime" $version.$r.load.$w.log | \
      awk  -v db=$version -v scenario="load" -v workload=$w -v replica=$r \
        'BEGIN {times=0;read=0;update=0;rmw=0;insert=0;scan=0} $1=="[OVERALL]," {time=$3} $1=="[READ]," {read=$3} $1=="[UPDATE]," {update=$3} $1=="[READ-MODIFY-WRITE]," {rmw=$3} $1=="[INSERT]," {insert=$3} $1=="[SCAN]," {scan=$3} END {print db "," scenario "," workload "," replica "," time "," read "," update "," rmw "," insert "," scan}' | \
        tee -a results.csv
      fi
      grep -e "Operations" -e "RunTime"  $version.$r.run.$w.log | \
        awk  -v db=$version -v scenario="run" -v workload=$w -v replica=$r \
        'BEGIN {times=0;read=0;update=0;rmw=0;insert=0;scan=0} $1=="[OVERALL]," {time=$3} $1=="[READ]," {read=$3} $1=="[UPDATE]," {update=$3} $1=="[READ-MODIFY-WRITE]," {rmw=$3} $1=="[INSERT]," {insert=$3} $1=="[SCAN]," {scan=$3} END {print db "," scenario "," workload "," replica "," time "," read "," update "," rmw "," insert "," scan}' | \
        tee -a results.csv
    done
  done
done


_crdb cloud=gce,region=us-west1,zone=us-west1-a cloud=gce,region=us-west1,zone=us-west1-b cloud=gce,region=us-west1,zone=us-west1-c cloud=gce,region=us-east1,zone=us-east1-a cloud=gce,region=us-east1,zone=us-east1-b cloud=gce,region=us-east1,zone=us-east1-c cloud=gce,region=us-central1,zone=us-central1-a cloud=gce,region=us-central1,zone=us-central1-b cloud=gce,region=us-central1,zone=us-central1-c 

_crdb cloud=gce,region=us-west1,zone=us-west1-a cloud=gce,region=us-east1,zone=us-east1-a  cloud=gce,region=us-central1,zone=us-central1-a 
