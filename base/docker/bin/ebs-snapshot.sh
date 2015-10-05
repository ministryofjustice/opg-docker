#!/bin/bash
export PATH=$PATH:/usr/local/bin/:/usr/bin

# Ensure any failed commands within a pipeline result in an appropriate exit code from the entire pipeline
set -o pipefail

## Automatic EBS Volume Snapshot Creation & Clean-Up Script
#
# Written by Casey Labs Inc. (https://www.caseylabs.com)
# Contact us for all your Amazon Web Services Consulting needs!
# Script Github repo: https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-bash
#
# Additonal credits: Log function by Alan Franzoni; Pre-req check by Colin Johnson
# Modified for The Ministry of Justice by David C Reay dcrbsltd@gmail.com
#
# PURPOSE: This Bash script can be used to take automatic snapshots of your Linux EC2 instance. Script process:
# - Determine the instance ID of the EC2 server on which the script runs
# - Gather a list of all volume IDs attached to that instance
# - Take a snapshot of each attached volume
# - The script will then delete all associated snapshots taken by the script that are older than 7 days
#
# DISCLAIMER: This script deletes snapshots (though only the ones that it creates).
# Make sure that you understand how the script works. No responsibility accepted in event of accidental data loss.
#

# See usage() for details on how to call this script
#

## Variable Declartions ##

# Who am I
SCRIPTNAME=$(echo "$(/usr/bin/basename ${0})")

# Set some other defaults for variables we could have been passed in e.g. docker env files
EBS_RETENTION_PERIOD=${EBS_SNAPSHOT_RETENTION_DAYS:-7}
MONITORING_HOST=${EBS_SNAPSHOT_MONITOR_HOST:-monitoring}
MONITORING_PORT=${EBS_SNAPSHOT_MONITOR_PORT:-2003}

# Setup some counters for volumes processed/successfull/failed
VOLUMES_TOTAL=0
VOLUMES_FAILED=0
VOLUMES_SUCCESS=0

# Get Instance Details
INSTANCE_ID=$(wget -q -O- http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(wget -q -O- http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/\([1-9]\).$/\1/g')

# Set Logging Options
LOGFILE="/var/log/ebs-snapshot.log"
LOGFILE_MAX_LINES="5000"

# How many days do you wish to retain backups for? Default: 7 days
RETENTION_DAYS="${EBS_RETENTION_PERIOD:=7}"
RETENTION_DATE_IN_SECONDS=$(date +%s --date "$RETENTION_DAYS days ago")

## Function Declarations ##

# Tell me how to use this script
usage() {
    echo "Usage: ${scriptname} -r|--runmode single|discover|volume [-v|--volume volume_id] -m|--metricpath metric_path [-d|--dryrun] -h|--help"
    echo ""
    echo "single:      Only backup EBS volumes belonging to this host"
    echo "discover:    Backup __ALL__ EBS volumes that this host can see"
    echo "volume:      Backup a specific volume based on a supplied volume id"
    echo "volume_id:   Volume id of volume to snapshot"
    echo "metric_path: Metric path to be used to log to Graphite e.g. production.production01.master"
    echo "dryrun:      Tell me what will be done without actually doing it"
    echo "help:        Display this usage"
    return
}

# Function: Setup logfile and redirect stdout/stderr.
log_setup() {
    # Check if logfile exists and is writable.
    ( [ -e "$LOGFILE" ] || touch "$LOGFILE" ) && [ ! -w "$LOGFILE" ] && echo "ERROR: Cannot write to $LOGFILE Check permissions or sudo access." && metrics_and_exit 1

    TMPLOG=$(tail -n $LOGFILE_MAX_LINES $LOGFILE 2>/dev/null) && echo "${TMPLOG}" > $LOGFILE
    exec > >(tee -a $LOGFILE)
    exec 2>&1
}

# Function: Log an event.
log() {
    echo "[$(date +"%Y-%m-%d"+"%T")]: $*"
}

# Function: Confirm that the AWS CLI and related tools are installed.
prerequisite_check() {
	for PREREQUISITE in aws wget; do
		hash $PREREQUISITE &> /dev/null
		if [[ $? == 1 ]]; then
			echo "In order to use this script, the executable \"$PREREQUISITE\" must be installed." 1>&2; metrics_and_exit 1
		fi
	done
}

# Function: Snapshot all volumes attached to this instance.
snapshot_volumes() {
	for VOLUME_ID in ${*}; do

		log "Volume ID is $VOLUME_ID"
		((VOLUMES_TOTAL++))

		# Get the attched device name to add to the description so we can easily tell which volume this is.
		DEVICE_NAME=$(aws ec2 describe-volumes --region $REGION --output=text --volume-ids $VOLUME_ID --query 'Volumes[0].{Devices:Attachments[0].Device}')

		# Take a snapshot of the current volume, and capture the resulting snapshot ID
		SNAPSHOT_DESCRIPTION="$INSTANCE_ID-$DEVICE_NAME-backup-$(date +%Y-%m-%d)"

		SNAPSHOT_ID=$(aws ec2 create-snapshot --region $REGION --output=text --description $SNAPSHOT_DESCRIPTION --volume-id $VOLUME_ID --query SnapshotId)
		RC=${?}
		log "New snapshot is $SNAPSHOT_ID"

		if [[ ${RC} -gt 0 ]] ; then
		  ((VOLUMES_FAILED++))
		else
		  ((VOLUMES_SUCCESS++))
		fi

		# Add a "CreatedBy:AutomatedBackup" tag to the resulting snapshot.
		# Why? Because we only want to purge snapshots taken by the script later, and not delete snapshots manually taken.
		aws ec2 create-tags --region $REGION --resource $SNAPSHOT_ID --tags Key=CreatedBy,Value=AutomatedBackup Key=Name,Value=AutomatedBackup
	done
}

# Function: Cleanup all snapshots associated with this instance that are older than $retention_days
cleanup_snapshots() {
	for VOLUME_ID in ${*}; do
		SNAPSHOT_LIST=$(aws ec2 describe-snapshots --region $REGION --output=text --filters "Name=volume-id,Values=$VOLUME_ID" "Name=tag:CreatedBy,Values=AutomatedBackup" --query Snapshots[].SnapshotId)
		for SNAPSHOT in $SNAPSHOT_LIST; do
			log "Checking $SNAPSHOT..."
			# Check age of snapshot
			SNAPSHOT_DATE=$(aws ec2 describe-snapshots --region $REGION --output=text --snapshot-ids $SNAPSHOT --query Snapshots[].StartTime | awk -F "T" '{printf "%s\n", $1}')
			SNAPSHOT_DATE_IN_SECONDS=$(date "--date=$SNAPSHOT_DATE" +%s)
			SNAPSHOT_DESCRIPTION=$(aws ec2 describe-snapshots --snapshot-id $SNAPSHOT --region $REGION --query Snapshots[].Description | tr '\n' ' ')

			if (( $SNAPSHOT_DATE_IN_SECONDS <= $RETENTION_DATE_IN_SECONDS )); then
				log "DELETING snapshot $SNAPSHOT. Description: $SNAPSHOT_DESCRIPTION ..."
				aws ec2 delete-snapshot --region $REGION --snapshot-id $SNAPSHOT
			else
				log "Not deleting snapshot $SNAPSHOT. Description: $SNAPSHOT_DESCRIPTION ..."
			fi
		done
	done
}

get_volumes() {
  aws ec2 describe-volumes --region $REGION --filters Name=attachment.instance-id,Values=$1 --query Volumes[].VolumeId --output text
}

# Record some graphite metrics so we can trigger alerts if needs be e.g. if we come here having processed no volumes and log a total volumes
# metric of zero we can set an alert to look out for zero counters.
metrics_and_exit() {
  EXITCODE=${1:-99}

  NOW=$(/bin/date '+%s')
  echo "${METRICPATH}.volumes_total ${VOLUMES_TOTAL} ${NOW}" | /bin/nc -q0 -w 60 ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_total ${VOLUMES_TOTAL} ${NOW}"

  echo "${METRICPATH}.volumes_failed ${VOLUMES_FAILED} ${NOW}" | /bin/nc -q0 -w 60 ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_failed ${VOLUMES_FAILED} ${NOW}"

  echo "${METRICPATH}.volumes_success ${VOLUMES_SUCCESS} ${NOW}" | /bin/nc -q0 -w 60 ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_success ${VOLUMES_SUCCESS} ${NOW}"

  exit ${EXITCODE}

}

# Process options and parameters

SHORTOPTS="hr:v:m:d"
LONGOPTS="help,runmode:,volume:,metricpath:,dryrun"

ARGS=$(getopt -s bash --options ${SHORTOPTS} \
	--longoptions ${LONGOPTS} -- "$@")
RC=${?}
if [[ ${RC} -ne 0 ]]; then
  usage
  exit 1
fi

eval set -- "${ARGS}"

while true; do
  case ${1} in
    -h|--help)
      usage
      exit 0
      ;;
    -r|--runmode)
      shift
      RUNMODE="${1}"
      ;;
    -v|--volume)
      shift
      VOLUMEID="${1}"
      ;;
    -m|--metricpath)
      shift
      METRICPATH="${1}"
      ;;
    -d|--dryrun)
      DRYRUN=1
      ;;
    --)
      shift
      break
      ;;
    *)
      shift
      break
      ;;
  esac
  shift
done

# Make sure we have everything we need
if [[ -z ${RUNMODE} ]] ; then
  echo "Run mode not specified"
  usage
  exit 1
elif [[ -z ${METRICPATH} ]] ; then
  echo "Metric path not specified"
  usage
  exit 1
elif [[ ${RUNMODE} != "single" && ${RUNMODE} != "discover" && ${RUNMODE} != "volume" ]] ; then
  echo "Invalid run mode"
  usage
  exit 1
elif [[ ${RUNMODE} == "volume"  && -z ${VOLUMEID} ]]; then
  echo "Volume ID not specified"
  usage
  exit 1
fi

# Log some runtime details
log "Running in ${RUNMODE} mode"
log "Recording to metric path ${METRICPATH}"
log "Logging metrics to ${MONITORING_HOST}:${MONITORING_PORT}"
log "Snapshots are retained for ${RETENTION_DAYS} days"

# Setup logging and make sure we have everything we need
log_setup
prerequisite_check

# Single mode: Just process the volumes for the instance I'm running on
# Discover: Go find all the instances you can and process the volumes they have
if [ "${RUNMODE}" == "single" ]; then
  VOLUME_LIST=$(get_volumes $INSTANCE_ID)
  if [[ "${DRYRUN}" ]] ; then
    log "Dryrun: Creating snapshots for instance ${INSTANCE_ID} of the following volumes: ${VOLUME_LIST}"
  else
    snapshot_volumes $VOLUME_LIST
    cleanup_snapshots $VOLUME_LIST
  fi
elif [ "${RUNMODE}" == "discover" ]; then
  INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
  for ID in $INSTANCE_IDS; do
    VOLUME_LIST=$(get_volumes $ID)
    if [[ "${DRYRUN}" ]] ; then
      log "Dryrun: Creating snapshots for instance ${ID} of the following volumes: ${VOLUME_LIST}"
    else
      snapshot_volumes $VOLUME_LIST
      cleanup_snapshots $VOLUME_LIST
    fi
  done
elif [ "${RUNMODE}" == "volume" ]; then
  if [[ "${DRYRUN}" ]] ; then
    log "Dryrun: Creating snapshots for volume ${VOLUMEID}"
  else
    snapshot_volumes ${VOLUMEID}
  fi
fi

# All done
if [[ ! ${DRYRUN} ]] ; then
  metrics_and_exit 0
fi

exit # should never get here
