#!/bin/sh

VERSION=1.0.1

docker build --build-arg ANGULAR=true -t netrist/devops-helper:$VERSION-angular .

docker build --build-arg ANGULAR=false -t netrist/devops-helper:$VERSION .


