#!/bin/bash

# $1 = cluster name
# $2 = port number 
# $3 = number of kind k8 worker(s) , to a maximum of 3 
# $4 = additional port number, in this for pre-production K8 namespace  
# $5 = additional port number, for future use 

echo "value of cluster name ==> $1"
echo "value of K8 port $2"
echo "value number of k8 worker(s) $3"

echo "Cleaning up unused Docker images..."

echo "kind: Cluster" > kind_k8_config.yaml
echo "apiVersion: kind.x-k8s.io/v1alpha4" >> kind_k8_config.yaml
echo "name: $1" >> kind_k8_config.yaml
echo "nodes:" >> kind_k8_config.yaml
echo "- role: control-plane"  >> kind_k8_config.yaml
echo "  extraPortMappings:" >> kind_k8_config.yaml
echo "  - containerPort: $2" >> kind_k8_config.yaml
echo "    hostPort: $2" >> kind_k8_config.yaml
#
if [ "$4" != "" ]; then
echo "  - containerPort: $4" >> kind_k8_config.yaml
echo "    hostPort: $4" >> kind_k8_config.yaml
fi
#
if [ "$5" != "" ]; then
echo "  - containerPort: $5" >> kind_k8_config.yaml
echo "    hostPort: $5" >> kind_k8_config.yaml
fi
#
if [ "$3" == "1" ]; then 
echo "- role: worker" >> kind_k8_config.yaml
fi
# 
if [ "$3" == "2" ]; then 
echo "- role: worker" >> kind_k8_config.yaml
echo "- role: worker" >> kind_k8_config.yaml
fi
if [ "$3" == "3" ]; then 
echo "- role: worker" >> kind_k8_config.yaml
echo "- role: worker" >> kind_k8_config.yaml
echo "- role: worker" >> kind_k8_config.yaml
fi