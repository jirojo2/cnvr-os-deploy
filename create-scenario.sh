#!/bin/bash

#
# To be executed in controller node
# ssh root@controller 'bash -s' < create-scenario.sh
#

# Clone / pull git repo
if [ -d cnvr-os-deploy ]
then
    echo "Updating deployment scripts..."
    pushd cnvr-os-deploy
    git pull
    popd
else
    echo "Cloning deployment scripts..."
    git clone https://github.com/jirojo2/cnvr-os-deploy.git
fi

# Create ExtNet as admin
source /root/bin/admin-openrc.sh
neutron net-create ExtNet --provider:physical_network external --provider:network_type flat --router:external --shared
neutron subnet-create --name ExtSubnet --allocation-pool start=10.0.10.100,end=10.0.10.200 --dns-nameserver 10.0.10.1 --gateway 10.0.10.1 ExtNet 10.0.10.0/24

# Downgrade privileges to regular user
source /root/bin/demo-openrc.sh

# Create security group rules to allow all traffic
openstack security group create open
openstack security group rule create --proto tcp --dst-port 1:65535 open
openstack security group rule create --proto udp --dst-port 1:65535 open
openstack security group rule create --proto icmp --dst-port -1 open

# Create internal network
neutron net-create Net1
neutron subnet-create Net1 10.1.1.0/24 --name Subnet1 --gateway 10.1.1.1 --dns-nameserver 8.8.8.8

# Create load balancer
neutron lbaas-loadbalancer-create --name lb1 Subnet1

# Create virtual machines
mkdir -p /root/keys
openstack keypair create scenario > /root/keys/scenario
openstack server create --flavor m1.smaller --image xenial-server-cloudimg-amd64-vnx adm --nic net-id=Net1 --key-name scenario --security-group open --user-data cloud-init/adm/user_data
openstack server create --flavor m1.smaller --image xenial-server-cloudimg-amd64-vnx db1 --nic net-id=Net1 --key-name scenario --security-group open --user-data cloud-init/db/user_data
openstack server create --flavor m1.smaller --image xenial-server-cloudimg-amd64-vnx s1 --nic net-id=Net1 --key-name scenario --security-group open --user-data cloud-init/www/user_data
openstack server create --flavor m1.smaller --image xenial-server-cloudimg-amd64-vnx s2 --nic net-id=Net1 --key-name scenario --security-group open --user-data cloud-init/www/user_data

# IPs
IP_LB=10.1.1.3
IP_ADM=10.1.1.4
IP_DB1=10.1.1.5
IP_S1=10.1.1.6
IP_S2=10.1.1.7

# Create external network
neutron router-create r0
neutron router-gateway-set r0 ExtNet
neutron router-interface-add r0 Subnet1

# Configure LBaaS
sleep 5
neutron lbaas-listener-create --loadbalancer lb1 --protocol HTTP --protocol-port 80 --name listener1
sleep 5
neutron lbaas-pool-create --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP --name pool1
sleep 2
neutron lbaas-member-create --subnet Subnet1 --address $IP_S1 --protocol-port 80 pool1
neutron lbaas-member-create --subnet Subnet1 --address $IP_S2 --protocol-port 80 pool1
neutron lbaas-healthmonitor-create --delay 3 --type HTTP --max-retries 3 --timeout 3 --pool pool1 --name hm1

# Assign floating IP address to lb
LB_ID=$( neutron lbaas-loadbalancer-list -c id -f value )
LB_VIP_PORT=$( neutron lbaas-loadbalancer-show -c vip_port_id -f value $LB_ID )
LB_FIP_ID=$( openstack ip floating create ExtNet -c id -f value )
neutron floatingip-associate $LB_FIP_ID $LB_VIP_PORT

# Assign floating IP address to adm
openstack ip floating add $( openstack ip floating create ExtNet -c ip -f value ) adm

# Create firewall (IPs internas)
neutron firewall-rule-create --name fw-rule-web --protocol tcp --destination-port 80 --destination-ip-address $IP_LB --action allow
neutron firewall-rule-create --name fw-rule-adm --protocol tcp --destination-port 4444 --destination-ip-address $IP_ADM --action allow
neutron firewall-rule-create --name fw-rule-int --protocol tcp --source-ip-address 10.0.0.0/8 --action allow
neutron firewall-policy-create --firewall-rules "fw-rule-web fw-rule-int" fw-policy1
neutron firewall-create --name fw1 --router r0 fw-policy1
