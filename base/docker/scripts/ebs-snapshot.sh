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

# Setup NC use
NC="/bin/nc -q0 -w 60"

# Set some other defaults for variables we could have been passed in e.g. docker env files
EBS_RETENTION_PERIOD=${EBS_SNAPSHOT_RETENTION_DAYS:-7}
MONITORING_HOST=${EBS_SNAPSHOT_MONITOR_HOST:-monitoring}
MONITORING_PORT=${EBS_SNAPSHOT_MONITOR_PORT:-2003}
SENSU_TTL=${EBS_SNAPSHOT_SENSU_TTL:-86400}
SENSU_PORT=${EBS_SNAPSHOT_SENSU_PORT:-3030}

# Setup some counters for volumes processed/successfull/failed/cleaned
VOLUMES_TOTAL=0
VOLUMES_FAILED=0
VOLUMES_SUCCESS=0
VOLUMES_CLEANED=0

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
  echo "Usage: ${SCRIPTNAME} -r|--runmode single|discover|volume [-v|--volume volume_id] -m|--metricpath metric_path [-d|--dryrun] -h|--help"
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
  if [[ "${DRYRUN}" ]] ; then
    echo "[$(date +"%Y-%m-%d"+"%T")]: (DRYRUN) $*"
  else
    echo "[$(date +"%Y-%m-%d"+"%T")]: $*"
  fi
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
    if [[ ! "${DRYRUN}" ]] ; then

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
    fi
	done
}

# Function: Cleanup all snapshots associated with this instance that are older than $RETENTION_DAYS
cleanup_snapshots() {
	for VOLUME_ID in ${*}; do
		SNAPSHOT_LIST=$(aws ec2 describe-snapshots --region $REGION --output=text --filters "Name=volume-id,Values=$VOLUME_ID" "Name=tag:CreatedBy,Values=AutomatedBackup" --query Snapshots[].SnapshotId)
		for SNAPSHOT in $SNAPSHOT_LIST; do
			log "Checking $SNAPSHOT..."
			# Check age of snapshot
			SNAPSHOT_DATE=$(aws ec2 describe-snapshots --region $REGION --output=text --snapshot-ids $SNAPSHOT --query Snapshots[].StartTime)
			SNAPSHOT_DATE_IN_SECONDS=$(date "--date=$SNAPSHOT_DATE" +%s)
      RC=${?}

      # Just in case the date doesn't render properly take the YYYY-MM-DD portion and use that
      if [[ ${RC} -ne 0 ]] ; then
        SNAPSHOT_DATE=$(echo ${SNAPSHOT_DATE} | awk -F "T" '{printf "%s\n", $1}')
        SNAPSHOT_DATE_IN_SECONDS=$(date "--date=$SNAPSHOT_DATE" +%s)
      fi

			SNAPSHOT_DESCRIPTION=$(aws ec2 describe-snapshots --snapshot-id $SNAPSHOT --region $REGION --query Snapshots[].Description | tr '\n' ' ')

			if (( $SNAPSHOT_DATE_IN_SECONDS <= $RETENTION_DATE_IN_SECONDS )); then
				log "DELETING snapshot $SNAPSHOT. Description: $SNAPSHOT_DESCRIPTION ; Taken: $(date -d @${SNAPSHOT_DATE_IN_SECONDS})"
        ((VOLUMES_CLEANED++))
        if [[ ! "${DRYRUN}" ]] ; then
				  aws ec2 delete-snapshot --region $REGION --snapshot-id $SNAPSHOT
        fi
			else
				log "Not deleting snapshot $SNAPSHOT. Description: $SNAPSHOT_DESCRIPTION ; Taken: $(date -d @${SNAPSHOT_DATE_IN_SECONDS})"
			fi
		done
	done
}

# Get volumes based on a filter value passed in
get_volumes() {
  aws ec2 describe-volumes --region $REGION --filters Name=attachment.instance-id,Values=$1 --query Volumes[].VolumeId --output text
}

# Get gateway IP address (used if inside docker to contact exposed host ports)
function get_gateway_ip() {

  IP=$(/sbin/ip route \
      | /usr/bin/awk '/default.*via/ {print $3}' \
      | /usr/bin/tr -d ' ')
  echo "${IP}"
}

# Record some graphite metrics so we can trigger alerts if needs be e.g. if we come here having processed no volumes and log a total volumes
# metric of zero we can set an alert to look out for zero counters. We'll also log a Sensu event here too so we can get to make sure it
# sees another one within a given period (TTL)
metrics_and_exit() {
  EXITCODE=${1:-99}
  EXITMSG="Completed"
  ((VOLUMES_CHECKSUM=${VOLUMES_TOTAL}-${VOLUMES_SUCCESS}-${VOLUMES_FAILED}))
  NOW=$(/bin/date '+%s')

  echo "${METRICPATH}.volumes_total ${VOLUMES_TOTAL} ${NOW}" | ${NC} ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_total ${VOLUMES_TOTAL} ${NOW}"

  echo "${METRICPATH}.volumes_failed ${VOLUMES_FAILED} ${NOW}" | ${NC} ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_failed ${VOLUMES_FAILED} ${NOW}"

  echo "${METRICPATH}.volumes_success ${VOLUMES_SUCCESS} ${NOW}" | ${NC} ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_success ${VOLUMES_SUCCESS} ${NOW}"

  echo "${METRICPATH}.volumes_cleaned ${VOLUMES_CLEANED} ${NOW}" | ${NC} ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_cleaned ${VOLUMES_CLEANED} ${NOW}"

  echo "${METRICPATH}.volumes_checksum ${VOLUMES_CHECKSUM} ${NOW}" | ${NC} ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${METRICPATH}.volumes_checksum ${VOLUMES_CHECKSUM} ${NOW}"

  GATEWAY="$(get_gateway_ip)"

  # Check some counters and set appropriate status code for the sensu event
  #
  if [[ "${VOLUMES_TOTAL}" -eq 0 ]] ; then
    EXITCODE=2
    EXITMSG="Zero volumes processed"
  elif [[ "${VOLUMES_FAILED}" -gt 0 ]] ; then
    EXITCODE=1
    EXITMSG="Volumes failed"
  elif [[ "${VOLUMES_CHECKSUM}" -gt 0 ]] ; then
    EXITCODE=3
    EXITMSG="Bad volume checksum"
  elif [[ "${VOLUMES_SUCCESS}" -eq 0 ]] ; then
    EXITCODE=1
    EXITMSG="Zero successfull volumes"
  fi

  echo '{"name": "'"${SCRIPTNAME}"'", "ttl": '"${SENSU_TTL}"', "output": "'"${EXITMSG}"'", "status": '"${EXITCODE}"'}' | ${NC} "${GATEWAY}" "${SENSU_PORT}"

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
log "Sensu client port is ${SENSU_PORT}"
log "Sensu alert TTL is ${SENSU_TTL}"

# Setup logging and make sure we have everything we need
log_setup
prerequisite_check

# Single mode: Just process the volumes for the instance I'm running on
# Discover: Go find all the instances you can and process the volumes they have
if [ "${RUNMODE}" == "single" ]; then
  VOLUME_LIST=$(get_volumes $INSTANCE_ID)
  snapshot_volumes $VOLUME_LIST
  cleanup_snapshots $VOLUME_LIST
elif [ "${RUNMODE}" == "discover" ]; then
  INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
  for ID in $INSTANCE_IDS; do
    VOLUME_LIST=$(get_volumes $ID)
    snapshot_volumes $VOLUME_LIST
    cleanup_snapshots $VOLUME_LIST
  done
elif [ "${RUNMODE}" == "volume" ]; then
  snapshot_volumes ${VOLUMEID}
fi

# All done
if [[ ! ${DRYRUN} ]] ; then
  metrics_and_exit 0
fi

exit 0 # get here on dry runs
