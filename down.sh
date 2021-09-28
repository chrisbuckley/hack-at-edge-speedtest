#!/bin/bash 

URL=https://speedtest.global.ssl.fastly.net/__down?bytes=100000000

rm -rf curl.out.g*

curl -L -o /dev/null "$URL" 2>&1 \
	| tr -u '\r' '\n' > curl.out

./curl_data.py curl.out

imgcat curl.out.png

