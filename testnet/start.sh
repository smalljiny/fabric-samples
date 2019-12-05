#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d ca.example.com orderer.example.com peer0.company.example.com couchdb
docker ps -a

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=CompanyMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@company.example.com/msp" peer0.company.example.com peer channel create -o orderer.example.com:7050 -c companychannel -f /etc/hyperledger/configtx/channel.tx
# Join peer0.company.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=CompanyMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@company.example.com/msp" peer0.company.example.com peer channel join -b companychannel.block
