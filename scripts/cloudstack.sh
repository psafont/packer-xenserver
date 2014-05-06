#!/bin/sh

cat > /etc/yum.repos.d/extra.repo<<EOT
[extra]
name=extra stuff
baseurl=http://192.168.100.10/RPMS 
gpgcheck=0
enabled=1
EOT

# These are all dependencies of the cloudstack host agent
sudo yum --enablerepo=base,extra --nogpgcheck -y install \
	jsvc \
	libvirt-python \
	java-1.7.0-openjdk \
	jakarta-commons-daemon \
	qemu-kvm \
	libvirt-python

