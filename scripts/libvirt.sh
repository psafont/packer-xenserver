#!/bin/sh

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

sudo yum --enablerepo=base,extra --nogpgcheck install libvirt-daemon libvirt-client libvirt libvirt-daemon-driver-xen -y

