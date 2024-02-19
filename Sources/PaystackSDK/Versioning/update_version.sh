#!/bin/bash

SEMANTIC_VERSION_MODE=$1
DESCRIPTION=$2

PLIST=./Versioning/versions.plist
CURRENT_VERSION=`/usr/libexec/PlistBuddy -c "Print Version" $PLIST`

INDEX=2 # Defaulting to patch
if [ "$SEMANTIC_VERSION_MODE" == 'major' ]; then
    INDEX=0
elif [ "$SEMANTIC_VERSION_MODE" == 'minor' ]; then
    INDEX=1
fi

VALUES=($(echo $CURRENT_VERSION | tr . '\n'))
VALUE=VALUES[INDEX]
INCREMENT=1
NEW_VALUE=$((VALUE + INCREMENT))
VALUES[INDEX]=$NEW_VALUE
if [ $INDEX -lt 2 ]; then VALUES[2]=0; fi
if [ $INDEX -lt 1 ]; then VALUES[1]=0; fi
NEW_VERSION=$(echo $(IFS=. ; echo "${VALUES[*]}"))

/usr/libexec/PlistBuddy -c "Set Version $NEW_VERSION" $PLIST
/usr/libexec/PlistBuddy -c "Set Description $DESCRIPTION" $PLIST
cd ../..
sed -i '' -e "s/.*s.version .*/  s.version          = '$NEW_VERSION'/" PaystackCore.podspec
sed -i '' -e "s/.*s.version .*/  s.version          = '$NEW_VERSION'/" PaystackUI.podspec
