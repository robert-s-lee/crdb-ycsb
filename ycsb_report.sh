#!/bin/bash

# the following variables are assumed
# db = db
# s = scenario
# w = w
# r = replica
_ycsb_report () {
  local db=${db:-db}
  local s=${s:-s}
  local w=${w:-w}
  local r=${r:-r}
  if [ ! -f results.csv ]; then
    echo "db,scenario,workload,replica,threads,mintime,maxtime,tpsmin,tpsmax,update,updateerr,read,readerr,rmw,rmwerr,scan,scanerr,insert,inserterr" > results.csv
  fi
  grep -e "Operations" -e "RunTime" -e "Using shards:" -e "Return=OK" | \
    awk  -v db=$db -v scenario=$s -v workload=$w -v replica=$r \
      'BEGIN {times=0;threads=0;batchsize=0;\
        read=0;update=0;rmw=0;insert=0;scan=0; \
        readerr=0;updateerr=0;rmwerr=0;inserterr=0;scanerr=0; } \
      $1=="Using" {threads=threads+1} \
      $1=="[OVERALL]," {if (time==0) {mintime=$3; maxtime=$3; time=$3;} if ($3 < mintime) {mintime=$3}; if ($4 > maxtime) {maxtime=$3};} \
      $1=="[READ],"         && $2=="Return=OK,"  {read=read+$3} \
      $1=="[READ-FAILED],"  && $2=="Operations," {readerr=readerr+$3} \
      $1=="[UPDATE],"       && $2=="Return=OK,"  {update=update+$3} \
      $1=="[UPDATE-FAILED],"      && $2=="Operations,"       {updateerr=updateerr+$3} \
      $1=="[READ-MODIFY-WRITE],"  && $2=="Return=OK,"        {rmw=rmw+$3} \
      $1=="[READ-MODIFY-WRITE-FAILED]," && $2=="Operations," {rmwerr=rmwerr+$3} \
      $1=="[INSERT],"         && $2=="Return=OK,"  {insert=insert+$3} \
      $1=="[INSERT-FAILED],"  && $2=="Operations," {inserterr=inserterr+$3} \
      $1=="[SCAN],"           && $2=="Return=OK,"  {scan=scan+$3} 
      $1=="[SCAN-FAILED],"    && $2=="Operations," {scanerr=scanerr+$3} 
      END {tps=read+scan+rmw+insert+update; \
           tpsmin=tps*1000/mintime; tpsmax=tps*1000/maxtime; \
           tpserr=readerr+scanerr+rmwerr+inserterr+updateerr; \
           tpserrmin=tsperr*1000/mintime; tpserrmax=tsperr*1000/maxtime; \
        print db "," scenario "," workload "," replica "," threads \
        "," mintime "," maxtime "," tpsmin "," tpsmax \
        "," update \
        "," updateerr \
        "," read \
        "," readerr \
        "," rmw \
        "," rmwerr \
        "," scan \
        "," scanerr \
        "," insert \
        "," inserterr \
      }' | \
    tee -a results.csv
}