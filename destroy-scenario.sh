#!/bin/bash

#
# To be executed in controller node
# ssh root@controller 'bash -s' < destroy-scenario.sh
#

source /root/bin/demo-openrc.sh

# Destroy virtual machines
for server in $( openstack server list -c ID -f value )
do
    openstack server delete $server
done

# Destroy floating ips
for fip in $( openstack ip floating list -c ID -f value )
do
    openstack ip floating delete $fip
done

# Destroy LB
neutron lbaas-healthmonitor-delete hm1
neutron lbaas-pool-delete pool1
neutron lbaas-listener-delete listener1
neutron lbaas-loadbalancer-delete lb1

# Destroy Net
neutron router-interface-delete r0 Subnet1
neutron router-gateway-clear r0
neutron router-delete r0
neutron subnet-delete Subnet1
neutron net-delete Net1

# Destroy ExtNet as admin
source /root/bin/admin-openrc.sh
neutron subnet-delete ExtSubnet
neutron net-delete ExtNet

# Destroy security group
openstack security group delete open

# Destroy the firewall
neutron firewall-delete fw1
neutron firewall-policy-delete fw-policy1
neutron firewall-rule-delete fw-rule-web
neutron firewall-rule-delete fw-rule-int
neutron firewall-rule-delete fw-rule-adm
