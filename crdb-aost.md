
add support for ` -p db.dialect=jdbc:cockroach[:{time interval}]`
- the default `time_interval` is `'-5s'`

## Build 

```bash
export YCSB_VER=0.18.0-SNAPSHOT
export YCSB=~/ycsb-jdbc-binding-$YCSB_VER
mvn -pl site.ycsb:jdbc-binding -am clean package
```

## Install
```bash
gzip -dc jdbc/target/ycsb-jdbc-binding-$YCSB_VER.tar.gz | tar -C ~ -xvf -
cd $YCSB/lib; curl -O --location https://jdbc.postgresql.org/download/postgresql-42.2.4.jar
```

## Test invalid dialects

## Test Default did not change existing behavior
```bash
cd $YCSB
# create table
java -cp lib/jdbc-binding-$YCSB_VER.jar:lib/postgresql-42.2.4.jar site.ycsb.db.JdbcDBCreateTable -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -p db.user=root -p db.passwd="" -n usertable 
# load initial data
bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p threadcount=3

```
## Test invalid dialect that will be using default
```bash
# workload A default
bin/ycsb run jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.dialect=xxxx -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1
```

### Test cockroach
```bash
# workload A default
bin/ycsb run jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1

# workload E default
bin/ycsb run jdbc -s -P workloads/workloade -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1
```

## Test db.dialect=jdbc:cockroach

should expect to see the variations of the following in the stdout
```
CockroachDB: Using AOST
Using database dialect: jdbc:cockroach
CockroachDB: SELECT * FROM usertable AS OF SYSTEM TIME '-5s' WHERE YCSB_KEY = ?
```

```bash
# workload A with db.dialect=jdbc:cockroach which uses as of system time (AOST) '-5s'
bin/ycsb run jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.dialect=jdbc:cockroach -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1

CockroachDB: Using AOST
Using database dialect: jdbc:cockroach
CockroachDB: SELECT * FROM usertable AS OF SYSTEM TIME '-5s' WHERE YCSB_KEY = ?

# workload A with db.dialect=jdbc:cockroach:-1s'
bin/ycsb run jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.dialect="jdbc:cockroach:'-1s'" -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1

CockroachDB: Using AOST
Using database dialect: jdbc:cockroach:'-1s'
CockroachDB: SELECT * FROM usertable AS OF SYSTEM TIME '-1s' WHERE YCSB_KEY = ?

# workload A with db.dialect=jdbc:cockroachexperimental_follower_read_timestamp()'
bin/ycsb run jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.dialect="jdbc:cockroach:experimental_follower_read_timestamp()" -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1

Using shards: 1, batchSize:128, fetchSize: 10
CockroachDB: Using AOST
Using database dialect: jdbc:cockroach:experimental_follower_read_timestamp()
CockroachDB: SELECT * FROM usertable AS OF SYSTEM TIME experimental_follower_read_timestamp() WHERE YCSB_KEY = ?

# workload E with db.dialect=jdbc:cockroach which uses as of system time (AOST) '-5s'
bin/ycsb run jdbc -s -P workloads/workloade -p db.driver=org.postgresql.Driver -p db.dialect=jdbc:cockroach -p db.url="jdbc:postgresql://127.0.0.1:26257/defaultdb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true&loadBalanceHosts=true" -p db.user=root -p db.passwd="" -p db.batchsize=128  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=128 -p recordcount=1000000 -p requestdistribution=uniform -p operationcount=300000 -p threadcount=1

CockroachDB: Using AOST
Using database dialect: jdbc:cockroach
CockroachDB: SELECT * FROM usertable AS OF SYSTEM TIME '-5s' WHERE YCSB_KEY >= ? ORDER BY YCSB_KEY LIMIT ?

```
