#!/bin/bash

#
# To be executed in controller node
# ssh root@controller 'bash -s' < destroy-s3.sh
#

source /root/bin/demo-openrc.sh

# Destroy virtual machines
for server in $( openstack server list -c ID -f value --name s3 )
do
    openstack server delete $server
done

neutron lbaas-member-delete lb-s3 pool1
