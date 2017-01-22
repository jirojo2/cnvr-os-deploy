#!/bin/bash

#
# To be executed in controller node
# ssh root@controller 'bash -s' < create-s3.sh
#

source /root/bin/demo-openrc.sh

IP_S3=10.1.1.8

openstack server create --flavor m1.smaller --image xenial-server-cloudimg-amd64-vnx s3 --nic net-id=Net1 --key-name scenario --security-group open --user-data cnvr-os-deploy/cloud-init/www/user_data
neutron lbaas-member-create --subnet Subnet1 --address $IP_S3 --protocol-port 80 pool1
