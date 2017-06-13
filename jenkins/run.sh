#!/bin/bash

set -x
set -e

branch=$1
server=$2
password=$3
apikey=$4
artifactory=$5

export PATH=/local/bigdisc/packer-bin:$PATH

boxbasedir=/usr/local/builds/vagrant
resultdir=/local/bigdisc/vagrant

escapedbranch=`echo $branch | sed sx/x%252Fxg`
vagrantboxname=`echo $branch | sed sx/x-xg`

VERSION=`curl "https://ratchet.do.citrite.net/job/xenserver-specs/job/$escapedbranch/api/json" | jq .lastSuccessfulBuild.number`

echo branch=$branch
echo VERSION=$VERSION
# Make a tmp dir to construct the box
boxdir=$boxbasedir/tmp-$branch

xva=$branch.$VERSION.xva
boxfile=$branch.$VERSION.box

rm -rf $boxdir
mkdir -p $boxdir
packer build -only=xenserver-iso -var "artifactory=$artifactory" -var "branch=$branch" -var "xshost=$server" -var "xspassword=$password" -var "outputdir=$boxdir" -var "version=$VERSION" internal/template-dev.json
rm -rf packer_cache/*
mkdir -p $resultdir/$branch
mv $boxdir/*.xva $resultdir/$branch/$xva
mkdir -p $resultdir/$branch
echo "{\"provider\": \"xenserver\"}" > $boxdir/metadata.json
cat > $boxdir/Vagrantfile << EOF
Vagrant.configure(2) do |config|
  config.vm.provider :xenserver do |xs|
    xs.xva_url = "http://xen-git.uk.xensource.com/vagrant/$branch/$xva"
  end
end
EOF
cd $boxdir
tar zcf $resultdir/$branch/$boxfile .
cd -

rm -rf $boxdir

pushd $resultdir/$branch
(ls -t|head -n 2;ls)|sort|uniq -u|xargs rm -f
popd

SHA=`sha1sum $resultdir/$branch/$boxfile | cut -d\  -f1`

cat > $resultdir/$branch/$branch.json <<EOF
{
  "name": "xenserver/$branch",
  "description": "This box contains XenServer installed from branch $branch",
  "versions": [{
    "version": "0.0.$VERSION",
    "providers": [{
      "name": "xenserver",
      "url": "http://xen-git.uk.xensource.com/vagrant/$branch/$boxfile",
      "checksum_type": "sha1",
      "checksum": "$SHA"
    }]
  }]
}
EOF

boxname=xs-$branch

echo boxname=$boxname

jenkins/create-vagrantcloud-box.sh $vagrantboxname $apikey
jenkins/update-vagrantcloud-box.sh $vagrantboxname 0.0.$VERSION http://xen-git.uk.xensource.com/vagrant/$branch/$boxfile $apikey


