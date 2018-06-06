#!/bin/sh
#
# Update dynamic address of my network.
#
# This script runs periodically (every 5 minutes, via cron) on a host on
# my network. It contacts the nsupdate service, which will identify the
# remote IP address and update the DNS if needed.
#
# The "sed" command at the end of the pipeline passes through messages
# about address changes or errors, but filters out messages indicating
# no change was made.
#

# URL of the web-nsupdate service.
SERVICE_URL="https://secure.soaustin.net/nsupdate.php"

# Name of the host in DNS that will be updated.
DNS_NAME="myrouter.example.com"

# The shared secret key for the nsupdate service.
KEY="CQqSmgor8zgE"

# Any options for curl.
# I used "--insecure" because I'm doing https with a self-signed certificate.
CURL_OPTS="--insecure"

# Force connection to IPv4 to be sure server gets correct external address.
curl -ipv4 --silent --show-error $CURL_OPTS \
  --data "hostname=$DNS_NAME" \
  --data "key=$KEY" \
  "$SERVICE_URL" \
  | sed -e '/already assigned to host/d'

