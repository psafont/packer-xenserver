#!/bin/bash
set -x

name=$1
version=$2
apikey=$3

json=`curl -H "X-Atlas-Token: $apikey" https://app.vagrantup.com/api/v1/box/jonludlam/$name/version/$version`
vcversion=`echo $json | jq -r .version`

if [ "0$version" == "0$vcversion" ]; then
   echo "yes"
else
   echo "no"
fi


