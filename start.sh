#!/bin/bash
cd /redis 
redis-server --daemonize yes
redis-cli set gateway 192.168.1.1

mkdir -p /opt/eblocker-icap/conf 
mkdir -p /opt/eblocker-icap/keys
mkdir -p /opt/eblocker-icap/network
mkdir -p /opt/eblocker-icap/registration
mkdir -p /opt/eblocker-icap/tmp
mkdir -p /opt/eblocker-network/bin
mkdir -p /opt/eblocker-lists/lists 

cp /configuration.properties /opt/eblocker-icap/conf/configuration.properties

cp /script_wrapper /opt/eblocker-network/bin/script_wrapper

cp -r /src/eblocker-lists/lists /opt/eblocker-lists/
cd /src/eblocker/eblocker-icapserver
mvn exec:exec