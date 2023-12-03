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

YEAR=`date "+%Y"`
MONTH=`date "+%m"`
DAY=`date "+%-d"`

if [ $MONTH -eq 12 -a $DAY -le 25 ]; then
	echo "It's advent of code"
else
	echo "TODO: allow arbitrary days"
	exit 1
fi

TARGET_DIR="./$YEAR/day$DAY"
TARGET_FILE="$TARGET_DIR/input"

if [ -e $TARGET_FILE ]; then
	echo "Repeat invocation prevented!"
	exit 1
fi

mkdir -p $TARGET_DIR
curl -s "https://adventofcode.com/$YEAR/day/$DAY/input" --cookie "session=$ADVENT_OF_CODE_SESSION" > $TARGET_FILE

echo "Downloaded $TARGET_FILE"