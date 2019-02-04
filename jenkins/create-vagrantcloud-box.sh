#!/bin/bash
set -x

name=$1
apikey=$2

curl https://app.vagrantup.com/api/v1/boxes -X POST -d box[name]="$name" -d box[is_private]=false -d box[username]=xenserver -d access_token=$apikey

