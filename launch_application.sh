#!/bin/bash

docker-compose up -d
sleep 10
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rake dev:prime
