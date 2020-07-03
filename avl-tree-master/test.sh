#!/bin/bash

TASK=example
EXEC=./$TASK
DIFF='diff -Bb'

#if which gtime > /dev/null; then
#  TIME=gtime
#elif [ -x /usr/bin/time ]; then
#  TIME=/usr/bin/time
#else
  echo "Cannot find a suitable time utility, turning timer off..."
  TIME=
#fi

OFFICIAL=0
WITH_LIMITS=0
LIMIT_CPU=1
LIMIT_STACK=65536
LIMIT_DATA=65536

function timer () {
  local OLD_LIMIT_CPU
  local OLD_LIMIT_STACK
  local OLD_LIMIT_DATA
  local result
  if [ $WITH_LIMITS -eq 1 ]; then
    OLD_LIMIT_CPU=`ulimit -S -t`
    OLD_LIMIT_STACK=`ulimit -S -s`
    OLD_LIMIT_DATA=`ulimit -S -d`
    ulimit -S -t $LIMIT_CPU 2> /dev/null
    ulimit -S -s $LIMIT_STACK 2> /dev/null
    ulimit -S -d $LIMIT_DATA 2> /dev/null
  fi
  if [ "$TIME" != "" ]; then
    $TIME --format="%U user %S system %E elapsed" "$@"
    result=$?
  else
    "$@"
    result=$?
    echo "OK" 1>&2
  fi
  if [ $WITH_LIMITS -eq 1 ]; then
    ulimit -S -t $OLD_LIMIT_CPU 2> /dev/null
    ulimit -S -s $OLD_LIMIT_STACK 2> /dev/null
    ulimit -S -d $OLD_LIMIT_DATA 2> /dev/null
  fi
  return $result
}

function usage () {
  printf "Usage: ./test.sh [options]\n\n"
  printf "Options\n-------\n"
  printf "  -g   : generate official solutions\n"
  printf "  -l   : with limits ($LIMIT_CPU sec., $LIMIT_STACK/$LIMIT_DATA KB mem\n"
  printf "  -t s : task name (default $TASK)\n"
  printf "  -x s : executable program (default $EXEC)\n"
  exit 0
}

while [ "$1" != "" ]; do
  case "$1" in
    -g)  OFFICIAL=1
         ;;
    -l)  WITH_LIMITS=1
         ;;
    -t)  shift
         TASK="$1"
         ;;
    -x)  shift
         EXEC="$1"
         ;;
    -*)  usage
         ;;
  esac
  shift
done

function testcase () {
  local s=`printf "%d" $1`
  local n=`printf "%d" $2`
  local infile
  local outfile
  if [ $s -eq 0 ]; then
    infile=testcases/$TASK.in$n
    outfile=testcases/$TASK.out$n
  else
    infile=testcases/subtask$s/$TASK.in$n
    outfile=testcases/subtask$s/$TASK.out$n
  fi
  if [ -e $infile.bz2 ]; then
    bzcat $infile.bz2 > $TASK.in
  elif [ -e $infile ]; then
    cp -f $infile $TASK.in
  else
    return 2
  fi
  if [ -e $outfile.bz2 ]; then
    bzcat $outfile.bz2 > $TASK.ans
  elif [ -e $outfile ]; then
    cp -f $outfile $TASK.ans
  fi
  if [ $s -eq 0 ]; then
    printf "test %s: " $n
  else
    printf "subtask %d, test %s: classified as " $s $n
  fi
  ./tester.py < $TASK.in
  if [ $? -ne 0 ]; then
    printf "BAD TEST !!!\n"
    rm -f $TASK.in $TASK.out $TASK.ans
    return 3
  fi
  timer $EXEC < $TASK.in > $TASK.out
  if [ $? -ne 0 ]; then
    printf "FAIL\n"
    rm -f $TASK.in $TASK.out $TASK.ans
    return 1
  fi
  local result=0
  if [ $OFFICIAL -eq 1 ]; then
    rm -f $TASK.in $TASK.ans
    mv -f $TASK.out $outfile
  else
    $DIFF $TASK.out $TASK.ans
    result=$?
    rm -f $TASK.in $TASK.out $TASK.ans
  fi
  return $result
}
s=1
n=0
while [ $s -gt 0 ]; do
  if [ ! -d "testcases/subtask$s" ]; then
    s=0
  fi
  ok=1
  bad=0
  declare -i points=0
  while true; do
    n=$((n+1))
    testcase $s $n
    case $? in
      0) if [ -f testcases.txt ]; then
           points+=`cat testcases.txt | grep "^ *$n:" | awk '{print $2}'`
         fi ;;
      1) ok=0 ;;
      2) n=$((n-1));
         break ;;
      3) bad=1 ;;
    esac
  done
  printf -- "---------------------------------------\n"
  if [ $s -gt 0 ]; then
    if [ $bad -ne 0 ]; then
      printf "Subtask %d is BAD\n\n" $s
    elif [ $ok -ne 0 ]; then
      printf "Subtask %d passed, $points point(s)\n\n" $s
    else
      printf "Subtask %d failed, $points point(s)\n\n" $s
    fi
    s=$((s+1))
  else
    printf "Total: $points point(s)\n\n"
  fi
done
