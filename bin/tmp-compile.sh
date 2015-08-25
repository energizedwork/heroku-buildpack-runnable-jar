#!/usr/bin/env bash

. manifest.sh

if [[ -z $HTTP_USER ]] || [[ -z $HTTP_PASSWORD ]]; then
    echo "Must specify HTTP_USER and HTTP_PASSWORD"
    exit 1
fi

echo "Downloading $ARTIFACT_URL"

authToken=$(echo "${HTTP_USER}:${HTTP_PASSWORD}" | base64)

s3location=$(wget -S -q --max-redirect=0 --auth-no-challenge --http-user=$HTTP_USER --http-password=$HTTP_PASSWORD --header 'Accept:application/vnd.snap-ci.com.v1+json' $ARTIFACT_URL 2>&1 | grep Location | sed 's/\s*Location: //g')
wget --header 'Accept:application/vnd.snap-ci.com.v1+json' -O application.jar $s3location