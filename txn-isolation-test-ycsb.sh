#!/bin/bash

# docker network so that names are resolved
docker network create mynet

# MariaDB
ycsb_mariadb_docker() {
    mkdir -p ~/var/lib/mariadb
    docker pull mariadb
    docker run --name mariadb --restart on-failure -p 3306:3306 -v ~/var/lib/mariadb:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=passw0rd -e MYSQL_DATABASE=ycsb -e MYSQL_USER=rslee -e MYSQL_PASSWORD=passw0rd -d mariadb
}

ycsb_mariadb_create() {
    docker exec -i mariadb mysql -urslee -ppassw0rd -Dycsb <<EOF
    CREATE TABLE usertable (
    YCSB_KEY VARCHAR(255) PRIMARY KEY,
    FIELD0 TEXT, FIELD1 TEXT,
    FIELD2 TEXT, FIELD3 TEXT,
    FIELD4 TEXT, FIELD5 TEXT,
    FIELD6 TEXT, FIELD7 TEXT,
    FIELD8 TEXT, FIELD9 TEXT
    );
EOF
}

ycsb_mariadb() {
    local operationcount=${operationcount:-100000}
    bin/ycsb run jdbc -s -P workloads/workload${1} -p db.driver=org.mariadb.jdbc.Driver -p db.url="jdbc:mariadb://localhost/ycsb?rewriteBatchedStatements=true"  -threads $thread -p db.user=rslee -p db.passwd="passw0rd" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p operationcount=${operationcount} -p db.isolationlevel=$txn | tee $DB.batchrewrite.$w.$txn.$thread.log
}
ycsb_mariadb_load() {
    local txn=""
    bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=org.mariadb.jdbc.Driver -p db.url="jdbc:mariadb://localhost/ycsb?rewriteBatchedStatements=true" -threads $thread -p db.user=rslee -p db.passwd="passw0rd" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p db.isolationlevel=$txn | tee $DB.batchrewrite.load.$txn.$thread.log
}

# MySQL
ycsb_mysql_docker() {
    mkdir -p ~/var/lib/mysql
    docker pull mysql
    docker run --name mysql --restart on-failure -p 3307:3306 -v ~/var/lib/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=passw0rd -e MYSQL_DATABASE=ycsb -e MYSQL_USER=rslee -e MYSQL_PASSWORD=passw0rd -d mysql
}

ycsb_mysql_create() {
    docker exec -i mysql mysql -urslee -ppassw0rd -Dycsb <<EOF
    CREATE TABLE ycsb.usertable (
    YCSB_KEY VARCHAR(255) PRIMARY KEY,
    FIELD0 TEXT, FIELD1 TEXT,
    FIELD2 TEXT, FIELD3 TEXT,
    FIELD4 TEXT, FIELD5 TEXT,
    FIELD6 TEXT, FIELD7 TEXT,
    FIELD8 TEXT, FIELD9 TEXT
    );
EOF
}
ycsb_mysql() {
    local operationcount=${operationcount:-100000}
    bin/ycsb run jdbc -s -P workloads/workload${1} -p db.driver=com.mysql.jdbc.Driver -p db.url="jdbc:mysql://localhost:3307/ycsb?rewriteBatchedStatements=true"  -threads $thread -p db.user=rslee -p db.passwd="passw0rd" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p operationcount=${operationcount} -p db.isolationlevel=$txn | tee $DB.batchrewrite.$w.$txn.$thread.log

}
ycsb_mysql_load() {
    local txn=""
    bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=com.mysql.jdbc.Driver -p db.url="jdbc:mysql://localhost:3307/ycsb?rewriteBatchedStatements=true" -threads $thread -p db.user=rslee -p db.passwd="passw0rd" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p db.isolationlevel=$txn | tee $DB.batchrewrite.load.$txn.$thread.log
}

# Postgres
ycsb_psql_docker() {
    mkdir -p ~/var/lib/postgres
    docker pull postgres
    docker run --name postgres --restart on-failure -p 5432:5432 -v ~/var/lib/postgres:/var/lib/postgres -e POSTGRES_PASSWORD=passw0rd -e POSTGRES_USER=rslee -e POSTGRES_DB=ycsb -e PGDATA=/var/lib/postgres -d postgres
}

ycsb_psql_create() {
    docker exec -i postgres psql -U rslee -d ycsb <<EOF
    CREATE TABLE usertable (
    YCSB_KEY VARCHAR(255) PRIMARY KEY,
    FIELD0 TEXT, FIELD1 TEXT,
    FIELD2 TEXT, FIELD3 TEXT,
    FIELD4 TEXT, FIELD5 TEXT,
    FIELD6 TEXT, FIELD7 TEXT,
    FIELD8 TEXT, FIELD9 TEXT
    );
EOF
}

ycsb_psql_truncate() {
    docker exec -i postgres psql -U rslee -d ycsb -c "truncate usertable;"
}

ycsb_psql() {
    local operationcount=${operationcount:-100000}    
    bin/ycsb run jdbc -s -P workloads/workload${1} -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:5432/ycsb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -threads $thread -p db.user=rslee -p db.passwd="passw0rd" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p operationcount=${operationcount} -p db.isolationlevel=$txn | tee $DB.batchrewrite.$w.$txn.$thread.log
}
ycsb_psql_load() {    
    local txn=""
    bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:5432/ycsb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -threads $thread -p db.user=rslee -p db.passwd="passw0rd" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=false -p db.batchsize=1000 -p recordcount=100000 -p db.isolationlevel=$txn | tee $DB.batchrewrite.load.$txn.$thread.log
}


# CockroachDB
ycsb_crdb_docker() {
    local tag=${tag:20.2.0}
    mkdir -p ~/var/lib/crdb
    docker pull cockroachdb/cockroach
    docker run -d --name=roach1 --hostname=roach1 --net=mynet -p 26257:26257 -p 26258:8080  -v ~/var/lib/crdb/roach1:/cockroach/cockroach-data cockroachdb/cockroach:$tag start  --insecure --join=roach1,roach2,roach3
    docker run -d --name=roach2 --hostname=roach2 --net=mynet -p 26259:26257 -p 26260:8080  -v ~/var/lib/crdb/roach2:/cockroach/cockroach-data cockroachdb/cockroach:$tag start --insecure --join=roach1,roach2,roach3
    docker run -d --name=roach3 --hostname=roach3 --net=mynet -p 26261:26257 -p 26262:8080  -v ~/var/lib/crdb/roach3:/cockroach/cockroach-data cockroachdb/cockroach:$tag start --insecure --join=roach1,roach2,roach3
    docker exec -it roach1 ./cockroach init --insecure
}

ycsb_crdb_create() {
    docker exec -i roach1 ./cockroach sql --insecure <<EOF
    create database ycsb;
    use ycsb;
    CREATE TABLE usertable (
    YCSB_KEY VARCHAR(255) PRIMARY KEY,
    FIELD0 TEXT, FIELD1 TEXT,
    FIELD2 TEXT, FIELD3 TEXT,
    FIELD4 TEXT, FIELD5 TEXT,
    FIELD6 TEXT, FIELD7 TEXT,
    FIELD8 TEXT, FIELD9 TEXT
    );
EOF
}

ycsb_crdb_truncate() {
    docker exec -i roach1 ./cockroach sql --insecure -d ycsb -e "truncate usertable;"
}
ycsb_crdb() {
    local operationcount=${operationcount:-100000}
    bin/ycsb run jdbc -s -P workloads/workload${1} -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/ycsb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -threads $thread -p db.user=root -p db.passwd="" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p operationcount=${operationcount} -p db.isolationlevel=$txn | tee $DB.batchrewrite.$w.$txn.$thread.log
}
ycsb_crdb_load() {    
    local txn=""
    bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:26257/ycsb?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -threads $thread -p db.user=root -p db.passwd="" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=false -p db.batchsize=1000 -p recordcount=100000 -p db.isolationlevel=$txn | tee $DB.batchrewrite.load.$txn.$thread.log
}


# YugaByte
ycsb_yb_docker() {
docker-compose -f - up <<EOF
version: '2'

volumes:
  yb-master-data-1:
  yb-tserver-data-1:

services:
  yb-master:
      image: yugabytedb/yugabyte:latest
      container_name: yb-master-n1
      volumes:
      - yb-master-data-1:/mnt/master
      command: [ "/home/yugabyte/bin/yb-master",
                "--fs_data_dirs=/mnt/master",
                "--master_addresses=yb-master-n1:7100",
                "--rpc_bind_addresses=yb-master-n1:7100",
                "--replication_factor=1"]
      ports:
      - "7000:7000"
      environment:
        SERVICE_7000_NAME: yb-master

  yb-tserver:
      image: yugabytedb/yugabyte:latest
      container_name: yb-tserver-n1
      volumes:
      - yb-tserver-data-1:/mnt/tserver
      command: [ "/home/yugabyte/bin/yb-tserver",
                "--fs_data_dirs=/mnt/tserver",
                "--start_pgsql_proxy",
                "--rpc_bind_addresses=yb-tserver-n1:9100",
                "--tserver_master_addrs=yb-master-n1:7100"]
      ports:
      - "9042:9042"
      - "5433:5433"
      - "9000:9000"
      environment:
        SERVICE_5433_NAME: ysql
        SERVICE_9042_NAME: ycql
        SERVICE_6379_NAME: yedis
        SERVICE_9000_NAME: yb-tserver
      depends_on:
      - yb-master
EOF
}

ycsb_yb_create() {
    docker exec -i yb-tserver-n1 /home/yugabyte/bin/ysqlsh -h yb-tserver-n1 <<EOF
    CREATE TABLE usertable (
           YCSB_KEY TEXT,
           FIELD0 TEXT, FIELD1 TEXT, FIELD2 TEXT, FIELD3 TEXT,
           FIELD4 TEXT, FIELD5 TEXT, FIELD6 TEXT, FIELD7 TEXT,
           FIELD8 TEXT, FIELD9 TEXT,
           PRIMARY KEY (YCSB_KEY ASC))
           SPLIT AT VALUES (('user10'),('user14'),('user18'),
           ('user22'),('user26'),('user30'),('user34'),('user38'),
           ('user42'),('user46'),('user50'),('user54'),('user58'),
           ('user62'),('user66'),('user70'),('user74'),('user78'),
           ('user82'),('user86'),('user90'),('user94'),('user98'));
EOF
}
ycsb_yb_truncate() {
    docker exec -i yb-tserver-n1 /home/yugabyte/bin/ysqlsh -h yb-tserver-n1 <<EOF
    truncate usertable;
EOF
}
ycsb_yb() {
    local operationcount=${operationcount:-100000}    
    bin/ycsb run jdbc -s -P workloads/workload${1} -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:5433/?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -threads $thread -p db.user=yugabyte -p db.passwd="" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p operationcount=${operationcount} -p db.isolationlevel=$txn | tee $DB.batchrewrite.$w.$txn.$thread.log
}
ycsb_yb_load() {    
    local txn=""
    bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=org.postgresql.Driver -p db.url="jdbc:postgresql://127.0.0.1:5433/?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true?autoReconnect=true&sslmode=disable&ssl=false&reWriteBatchedInserts=true" -threads $thread -p db.user=yugabyte -p db.passwd="" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=false -p db.batchsize=1000 -p recordcount=100000 -p db.isolationlevel=$txn | tee $DB.batchrewrite.load.$txn.$thread.log
}

# TiDB

ycsb_tidb_docker() {
    local tag=${tag:latest}
    mkdir -p ~/var/lib/tidb
    git clone https://github.com/pingcap/tidb-docker-compose.git ~/var/lib/tidb
    cd ~/var/lib/tidb && docker-compose pull # Get the latest Docker images
    docker-compose up -d
$ docker-compose up -d
$ mysql -h 127.0.0.1 -P 4000 -u root
}

ycsb_tidb_create() {
    docker run -i --rm --network tidb_default arey/mysql-client -h tidb_tidb_1 -P 4000 -u root <<EOF
    create database ycsb;
    use ycsb;
    CREATE TABLE usertable (
    YCSB_KEY VARCHAR(255) PRIMARY KEY,
    FIELD0 TEXT, FIELD1 TEXT,
    FIELD2 TEXT, FIELD3 TEXT,
    FIELD4 TEXT, FIELD5 TEXT,
    FIELD6 TEXT, FIELD7 TEXT,
    FIELD8 TEXT, FIELD9 TEXT
    );
EOF
}

ycsb_tidb() {
    local operationcount=${operationcount:-100000}
    bin/ycsb run jdbc -s -P workloads/workload${1} -p db.driver=com.mysql.jdbc.Driver -p db.url="jdbc:mysql://localhost:4000/ycsb?rewriteBatchedStatements=true"  -threads $thread -p db.user=root -p db.passwd="" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p operationcount=${operationcount} -p db.isolationlevel=$txn | tee $DB.batchrewrite.$w.$txn.$thread.log
}
ycsb_tidb_load() {
    local txn=""
    bin/ycsb load jdbc -s -P workloads/workloada -p db.driver=com.mysql.jdbc.Driver -p db.url="jdbc:mysql://localhost:4000/ycsb?rewriteBatchedStatements=true" -threads $thread -p db.user=root -p db.passwd="" -p db.batchsize=1000  -p jdbc.fetchsize=10 -p jdbc.autocommit=true -p jdbc.batchupdateapi=true -p db.batchsize=1000 -p recordcount=100000 -p db.isolationlevel=$txn | tee $DB.batchrewrite.load.$txn.$thread.log
}


