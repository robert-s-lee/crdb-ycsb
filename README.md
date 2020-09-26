# open source YCSB usage on CRDB

- [batch to multi row rewrite](https://github.com/brianfrankcooper/YCSB/pull/1220)
- [as of system time examples](./crdb-aost.md) using [test build](./ycsb-jdbc-binding-0.18.0-SNAPSHOT.tar.gz)


# cockroach built-in ycsb client usage:
```
cockroach sql --insecure -d ycsb -e "drop table if exists usertable;"
workload init ycsb --families=false --insert-count=10
workload init ycsb --families=false --insert-count=10 --insert-hash=false 
workload init ycsb --families=false --insert-count=10 --insert-hash=false --zero-padding=1
cockroach sql --insecure -d ycsb -e "select * from usertable;"
workload run ycsb --families=false --insert-count=10 --workload='a' --max-rate=1
workload run ycsb --families=false --insert-count=10 --workload='a' --insert-hash=false --max-rate=1
workload run ycsb --families=false --insert-count=10 --workload='a' --insert-hash=false --zero-padding=6 --max-rate=1
cockroach sql --insecure -d ycsb -e "select * from usertable;"
workload run ycsb --families=false --insert-count=10 --workload='a' --time-string=true --max-rate=1 
workload run ycsb --families=false --insert-count=10 --workload='a' --insert-hash=false --time-string=true --max-rate=1 
workload run ycsb --families=false --insert-count=10 --workload='a' --insert-hash=false --zero-padding=6 --time-string=true --max-rate=1 
for i in $(seq 0 9); do cockroach sql --insecure -d ycsb -e "select ycsb_key,field${i} from usertable;"; done


workload run ycsb --families=false --insert-count=10 --workload='a' --duration=1m --time-string=true
workload run ycsb --families=false --insert-count=10 --workload='a' --insert-hash=false --duration=1m --time-string=true
workload run ycsb --families=false --insert-count=10 --workload='a' --insert-hash=false --zero-padding=6 --duration=1m --time-string=true
```

# geo partitioning on list

```
alter table usertable add column pk_prefix string AS (left(ycsb_key,6)) STORED NOT NULL;
alter table usertable add column pk_suffix string AS (substr(ycsb_key,7)) STORED NOT NULL;
ALTER TABLE usertable ALTER PRIMARY KEY USING COLUMNS (pk_prefix,pk_suffix);
alter table usertable PARTITION BY LIST (pk_prefix) (
    PARTITION ycsb_usertable_west VALUES    in ('user1'),
    PARTITION ycsb_usertable_central VALUES in ('user2'),
    PARTITION ycsb_usertable_east VALUES    in ('user3')
);
```
# geo partitioning on range
```
ALTER TABLE usertable ALTER PRIMARY KEY USING COLUMNS (ycsb_key);
alter table usertable PARTITION BY RANGE (YCSB_KEY) (
    PARTITION ycsb_usertable_west VALUES    FROM (MINVALUE) to ('user2'),
    PARTITION ycsb_usertable_central VALUES FROM ('user2')  to ('user3'),
    PARTITION ycsb_usertable_east VALUES    FROM ('user4')  to (MAXVALUE)
);
```

# does not change whether list or range partitioning
```
ALTER PARTITION ycsb_usertable_west OF TABLE usertable CONFIGURE ZONE USING constraints='[+region=west]';
ALTER PARTITION ycsb_usertable_central OF TABLE usertable CONFIGURE ZONE USING constraints='[+region=central]';
ALTER PARTITION ycsb_usertable_east OF TABLE usertable CONFIGURE ZONE USING constraints='[+region=east]';

ALTER PARTITION ycsb_usertable_west OF TABLE usertable CONFIGURE ZONE USING lease_preferences='[[+region=west]]';
ALTER PARTITION ycsb_usertable_central OF TABLE usertable CONFIGURE ZONE USING lease_preferences='[[+region=central]]';
ALTER PARTITION ycsb_usertable_east OF TABLE usertable CONFIGURE ZONE USING lease_preferences='[[+region=east]]';
```

