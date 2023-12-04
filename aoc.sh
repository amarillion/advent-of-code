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

# If there are exactly 2 arguments...
if [[ $# -eq 2 ]]; then
	YEAR=$1
	DAY=$2
	if [ $YEAR -lt 2015 -o $DAY -gt 25 ]; then
		echo "Not a suitable AOC date"
		echo "Expected: `aoc YEAR DAY`, or just `aoc` to get current day during the event"
		exit 1
	fi
# Exactly zero arguments
elif [[ $# -eq 0 ]]; then
	YEAR=`date "+%Y"`
	MONTH=`date "+%m"`
	DAY=`date "+%-d"`

	if [ $MONTH -ne 12 -o $DAY -gt 25 ]; then
		echo "Arguments needed"
		echo "Expected: `aoc YEAR DAY`, or just `aoc` to get current day during the event"
		exit 1
	fi
else
	echo "Wrong number of arguments"
	echo "Expected: `aoc YEAR DAY`, or just `aoc` to get current day during the event"
	exit 1
fi

echo "Processing with year: $YEAR day: $DAY"

TARGET_DIR="./$YEAR/day$DAY"
TARGET_FILE="$TARGET_DIR/input"

if [ -e $TARGET_FILE ]; then
	echo "Repeat invocation prevented!"
	exit 1
fi

mkdir -p $TARGET_DIR
curl -s "https://adventofcode.com/$YEAR/day/$DAY/input" --cookie "session=$ADVENT_OF_CODE_SESSION" > $TARGET_FILE

echo "Downloaded $TARGET_FILE"
