#!/bin/sh
clear && aqueduct serve -n 1 --ssl-certificate-path ../../certs/fullchain.pem --ssl-key-path ../../certs/privkey.pem > errors.log 2>&1
