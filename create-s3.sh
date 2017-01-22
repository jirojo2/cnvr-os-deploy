#!/bin/bash

#
# To be executed in controller node
# ssh root@controller 'bash -s' < create-s3.sh
#

source /root/bin/demo-openrc.sh

openstack server create --flavor m1.smaller --image xenial-server-cloudimg-amd64-vnx s3 --nic net-id=Net1 --key-name scenario --security-group open --user-data cnvr-os-deploy/cloud-init/www/user_data

sleep 10
S3_NET=$( openstack server show -c addresses -f value s3 )
S3_IP=${S3_NET/Net1=/}

neutron lbaas-member-create --name lb-s3 --subnet Subnet1 --address $S3_IP --protocol-port 80 pool1
