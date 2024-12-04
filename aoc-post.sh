#!/bin/bash

#accessing through symlink?
if [ -h $0 ]
then
        # change to directory of target of symlink
        TARGET=`readlink $0`
        cd $(dirname $TARGET)
else
        # change to directory of this script
        cd $(dirname $0)
fi

INFO="Expected: 'aoc-post LEVEL YEAR DAY', or just 'aoc-post LEVEL' during the event"

# If there are exactly 3 arguments...
if [[ $# -eq 3 ]]; then
	LEVEL=$1
	YEAR=$2
	DAY=$3
	if [ $YEAR -lt 2015 -o $DAY -gt 25 ]; then
		echo "Not a suitable AOC date"
		echo $INFO
		exit 1
	fi
# Exactly one arguments
elif [[ $# -eq 1 ]]; then
	LEVEL=$1
	YEAR=`date "+%Y"`
	MONTH=`date "+%m"`
	DAY=`date "+%-d"`
	if [ $MONTH -ne 12 -o $DAY -gt 25 ]; then
		echo "Wrong day or month"
		echo $INFO
		exit 1
	fi
else
	echo "Wrong number of arguments"
	echo $INFO
	exit 1
fi

if [[ $LEVEL -ne 1 && $LEVEL -ne 2 ]]; then
	echo "Level must be 1 or 2"
	echo $INFO
	exit 1
fi

echo "Reading input with year: $YEAR day: $DAY level: $LEVEL"

ANSWER=$(tail -n 1)

echo curl -X POST -d "level=$LEVEL" -d "answer=$ANSWER" -s "https://adventofcode.com/$YEAR/day/$DAY/answer" --cookie "session=$ADVENT_OF_CODE_SESSION"
curl -X POST -d "level=$LEVEL" -d "answer=$ANSWER" -s "https://adventofcode.com/$YEAR/day/$DAY/answer" --cookie "session=$ADVENT_OF_CODE_SESSION"
