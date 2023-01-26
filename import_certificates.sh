#!/usr/bin/env sh

KEYSTORE_FILE=./keystore.jks
KEYSTORE_PASS=changeit

import_cert() {
  echo 
  echo "Importing for "$1
  local HOST=$1
  local PORT=$2

  IFS=' ' read -ra ADDR <<< "$1"
  
  HOST=${ADDR[0]}

  if [ ${#ADDR[@]} == 2 ]
  then
    PORT=${ADDR[1]}
  fi

  if [[ -z $PORT ]]; then
    PORT=443
  fi

  echo host = $HOST
  echo port = $PORT

  # get the SSL certificate
  openssl s_client -connect ${HOST}:${PORT} </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOST}.cert

  # delete the old alias and then import the new one
  keytool -delete -keystore ${KEYSTORE_FILE} -storepass ${KEYSTORE_PASS} -alias ${HOST} &> /dev/null

  # create a keystore (or update) and import certificate
  keytool -import -noprompt -trustcacerts \
      -alias ${HOST} -file ${HOST}.cert \
      -keystore ${KEYSTORE_FILE} -storepass ${KEYSTORE_PASS}

  # remove temp file
  rm ${HOST}.cert
}

# Change your sites here
# import_cert stackoverflow.com 443
# import_cert www.google.com # default port 443
# import_cert 172.217.194.104 443 # google

array=(
"stackoverflow.com 443"
www.google.com
"172.217.194.104 443"
)

for i in "${array[@]}"
do
	import_cert "$i"
done