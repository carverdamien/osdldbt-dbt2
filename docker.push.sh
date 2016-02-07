#!/bin/bash
IMG="carverdamien/$(basename $PWD)"
docker build -t ${IMG} .
docker push ${IMG}
