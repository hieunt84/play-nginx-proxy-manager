#!/bin/bash
# Script deploy nginx-proxy-manager with docker

# deploy
docker-compose up -d

# verify
docker-compose ps