#!/bin/bash

export DB 
# export operationcount=10000
for DB in tidb; do # mariadb mysql psql crdb yb
    for thread in 1 2 3; do
        for txn in TRANSACTION_READ_UNCOMMITTED TRANSACTION_READ_COMMITTED TRANSACTION_REPEATABLE_READ TRANSACTION_SERIALIZABLE; do
            for w in a b c f; do
                cmd="ycsb_$DB $w"
                echo $cmd
                eval $cmd
            done
        done
    done
done