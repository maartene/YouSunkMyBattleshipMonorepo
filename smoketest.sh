#!/bin/bash
echo "Starting containers"
podman compose up --build -d
sleep 5s
echo "Run tests"
cd api/contract/YouSunkMyBattleship
bru run
echo "Cleanup"
cd ../../..
podman compose down