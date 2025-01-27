#!/usr/bin/env sh

# Example: ./upload_to_minio example.url.com username password bucket-name internal/minio/path /absolute/path/file.txt.zst

if [ -z $1 ]; then
  echo "You have NOT specified a MINIO URL!"
  exit 1
fi

if [ -z $2 ]; then
  echo "You have NOT specified a USERNAME!"
  exit 1
fi

if [ -z $3 ]; then
  echo "You have NOT specified a PASSWORD!"
  exit 1
fi

if [ -z $4 ]; then
  echo "You have NOT specified a BUCKET!"
  exit 1
fi

if [ -z $5 ]; then
  echo "You have NOT specified a UPLOAD PATH!"
  exit 1
fi

if [ -z $6 ]; then
  echo "You have NOT specified a UPLOAD FILE!"
  exit 1
fi


# User Minio Vars
URL=$1
USERNAME=$2
PASSWORD=$3
BUCKET=$4
FILE_NAME=$(basename $6)
OBJ_PATH="/${BUCKET}/$5/${FILE_NAME}"

# Static Vars
DATE=$(date -R --utc)
CONTENT_TYPE='application/zstd'
SIG_STRING="PUT\n\n${CONTENT_TYPE}\n${DATE}\n${OBJ_PATH}"
SIGNATURE=`echo -en ${SIG_STRING} | openssl sha1 -hmac ${PASSWORD} -binary | base64`

curl --silent -v -X PUT -T "${FILE_NAME}" \
    -H "Host: $URL" \
    -H "Date: ${DATE}" \
    -H "Content-Type: ${CONTENT_TYPE}" \
    -H "Authorization: AWS ${USERNAME}:${SIGNATURE}" \
    http://$URL${OBJ_PATH}