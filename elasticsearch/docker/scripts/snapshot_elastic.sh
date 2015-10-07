#!/bin/bash
#
# Create a repository for snapshots (if on S3 force server side encryption). Then take a snapshot of indices to it. Then delete snapshots older than a certain period.
#
# Uses the following environment variables (using sensible defaults if not set):
#
# ELASTICSEARCH_SNAPSHOTS_HOSTNAME              (name of elasticsearch host)
# ELASTICSEARCH_SNAPSHOTS_PORT                  (port elasticsearch host listens on)
# ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE       (should be s3 (Amazon S3) or fs (Filesystem))
# ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET  (name of S3 bucket)
# ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_PATH    (path within the bucket to repository data)
# ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH    (path to filesystem based repository)
# ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME       (name of the repository into which snapshots are take)
# ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS           (how many days to retain snapshots for)
#

# Set defaults
#
ELASTICSEARCH_SNAPSHOTS_HOSTNAME=${ELASTICSEARCH_SNAPSHOTS_HOSTNAME:-elasticsearch}
ELASTICSEARCH_SNAPSHOTS_PORT=${ELASTICSEARCH_SNAPSHOTS_PORT:-9200}
ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE=${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE:-s3}
ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET=${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET:-snapshots}
ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_PATH=${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_PATH:-/}
ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH=${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH:-/usr/share/elasticsearch/repo/snapshots}
ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME=${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME:-snapshot_repo}
ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS=${ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS:-7}

# Main
#
echo "Elasticsearch host is ${ELASTICSEARCH_SNAPSHOTS_HOSTNAME} (port ${ELASTICSEARCH_SNAPSHOTS_PORT})"
echo "Creating repository called ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME} on ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE}"
case ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE} in
s3)
  echo "Creating repository in S3 bucket ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET}"
  json='{ "type": "s3", "settings": { "bucket": "'${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET}'", "base_path": "'${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME}/${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_PATH}'", "compress": "true", "server_side_encryption": "true", "wait_for_completion": "true" } }'
  ;;
fs)
  echo "Creating repository in FS path ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH}"
  json='{ "type": "fs", "settings": { "location": "'${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH}'", "compress": "true", "wait_for_completion": "true" } }'
  ;;
*)
  echo "Invalid repository type specified ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE}"
  exit 3
  ;;
esac

result=$(eval curl -s -XPUT "http://${ELASTICSEARCH_SNAPSHOTS_HOSTNAME}:${ELASTICSEARCH_SNAPSHOTS_PORT}/_snapshot/${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME}" -d "'"${json}"'")
check=$(echo ${result} | awk '/acknowledged.*true/')
if [ "${check}" = "" ] ; then
  echo "${result}"
  echo "Error creating repository ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME}"
  exit 2
fi
echo "Repository created successfully"

curator --host ${ELASTICSEARCH_SNAPSHOTS_HOSTNAME} snapshot --repository ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME} indices --all-indices
rc=$?
if [ "${rc}" -ne 0 ] ; then
  echo "Error ${rc} from curator snapshot indices"
  exit 2
fi
echo "Snapshot created successfully"

echo "Removing snapshots older than ${ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS} days"
curator --host ${ELASTICSEARCH_SNAPSHOTS_HOSTNAME} delete snapshots --repository ${ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME} --older-than ${ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS} --time-unit days
rc=$?
if [ "${rc}" -ne 0 ] ; then
  echo "Error ${rc} from curator delete snapshot"
  exit 1
fi

echo "Snapshot process completed successfully"
exit 0
