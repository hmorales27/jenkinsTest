#!/bin/bash

echo $1
echo $2

/usr/libexec/PlistBuddy -c "Set productionAppKey "$1 ../AirshipConfig.plist
/usr/libexec/PlistBuddy -c "Set productionAppSecret "$2 ../AirshipConfig.plist
/usr/libexec/PlistBuddy -c "Set developmentAppKey $3" ../AirshipConfig.plist
/usr/libexec/PlistBuddy -c "Set developmentAppSecret $4" ../AirshipConfig.plist
