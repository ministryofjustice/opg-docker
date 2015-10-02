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

# Paramerters that can be passed
#
# 1st: single | discover (default is single)
# 2nd: Graphite metric path used to construct metrics sent off (default is constructed using instance id and host name)

## Variable Declartions ##

# Who am I (remove dots so they do not appear in the metric)
scriptname=$(echo "$(/usr/bin/basename ${0})" \
		| /usr/bin/tr -d '.')

# Pull in parameters setting defaults for any not passed
runmode=${1:-single}
thishost=$(/bin/hostname -s)
instance=$(wget -q -O- http://169.254.169.254/latest/meta-data/instance-id)
thisinstance=${instance:-Unknown}
metricpath=${2-Unknown.${thisinstance}.${thishost}.${scriptname}}

# Set some other defaults for variables we could have been passed in e.g. docker env files
EBS_RETENTION_PERIOD=${EBS_SNAPSHOT_RETENTION_DAYS:-7}
MONITORING_HOST=${EBS_SNAPSHOT_MONITOR_HOST:-monitoring}
MONITORING_PORT=${EBS_SNAPSHOT_MONITOR_PORT:-2003}

# Setup some counters for volumes processed/successfull/failed
volumes_total=0
volumes_failed=0
volumes_success=0

# Get Instance Details
instance_id=$(wget -q -O- http://169.254.169.254/latest/meta-data/instance-id)
region=$(wget -q -O- http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/\([1-9]\).$/\1/g')

# Set Logging Options
logfile="/var/log/ebs-snapshot.log"
logfile_max_lines="5000"

# How many days do you wish to retain backups for? Default: 7 days
retention_days="${EBS_RETENTION_PERIOD:=7}"
retention_date_in_seconds=$(date +%s --date "$retention_days days ago")

## Function Declarations ##

# Function: Setup logfile and redirect stdout/stderr.
log_setup() {
    # Check if logfile exists and is writable.
    ( [ -e "$logfile" ] || touch "$logfile" ) && [ ! -w "$logfile" ] && echo "ERROR: Cannot write to $logfile. Check permissions or sudo access." && metrics_and_exit 1

    tmplog=$(tail -n $logfile_max_lines $logfile 2>/dev/null) && echo "${tmplog}" > $logfile
    exec > >(tee -a $logfile)
    exec 2>&1
}

# Function: Log an event.
log() {
    echo "[$(date +"%Y-%m-%d"+"%T")]: $*"
}

# Function: Confirm that the AWS CLI and related tools are installed.
prerequisite_check() {
	for prerequisite in aws wget; do
		hash $prerequisite &> /dev/null
		if [[ $? == 1 ]]; then
			echo "In order to use this script, the executable \"$prerequisite\" must be installed." 1>&2; metrics_and_exit 70
		fi
	done
}

# Function: Snapshot all volumes attached to this instance.
snapshot_volumes() {
	for volume_id in ${*}; do

		log "Volume ID is $volume_id"
		((volumes_total++))

		# Get the attched device name to add to the description so we can easily tell which volume this is.
		device_name=$(aws ec2 describe-volumes --region $region --output=text --volume-ids $volume_id --query 'Volumes[0].{Devices:Attachments[0].Device}')

		# Take a snapshot of the current volume, and capture the resulting snapshot ID
		snapshot_description="$(hostname)-$device_name-backup-$(date +%Y-%m-%d)"

		snapshot_id=$(aws ec2 create-snapshot --region $region --output=text --description $snapshot_description --volume-id $volume_id --query SnapshotId)
		rc=${?}
		log "New snapshot is $snapshot_id"

		if [[ ${rc} -gt 0 ]] ; then
		  ((volumes_failed++))
		else
		  ((volumes_success++))
		fi
	 
		# Add a "CreatedBy:AutomatedBackup" tag to the resulting snapshot.
		# Why? Because we only want to purge snapshots taken by the script later, and not delete snapshots manually taken.
		aws ec2 create-tags --region $region --resource $snapshot_id --tags Key=CreatedBy,Value=AutomatedBackup
	done
}

# Function: Cleanup all snapshots associated with this instance that are older than $retention_days
cleanup_snapshots() {
	for volume_id in ${*}; do
		snapshot_list=$(aws ec2 describe-snapshots --region $region --output=text --filters "Name=volume-id,Values=$volume_id" "Name=tag:CreatedBy,Values=AutomatedBackup" --query Snapshots[].SnapshotId)
		for snapshot in $snapshot_list; do
			log "Checking $snapshot..."
			# Check age of snapshot
			snapshot_date=$(aws ec2 describe-snapshots --region $region --output=text --snapshot-ids $snapshot --query Snapshots[].StartTime | awk -F "T" '{printf "%s\n", $1}')
			snapshot_date_in_seconds=$(date "--date=$snapshot_date" +%s)
			snapshot_description=$(aws ec2 describe-snapshots --snapshot-id $snapshot --region $region --query Snapshots[].Description | tr '\n' ' ')

			if (( $snapshot_date_in_seconds <= $retention_date_in_seconds )); then
				log "DELETING snapshot $snapshot. Description: $snapshot_description ..."
				aws ec2 delete-snapshot --region $region --snapshot-id $snapshot
			else
				log "Not deleting snapshot $snapshot. Description: $snapshot_description ..."
			fi
		done
	done
}	

get_volumes() {
  aws ec2 describe-volumes --region $region --filters Name=attachment.instance-id,Values=$1 --query Volumes[].VolumeId --output text
}

# Record some graphite metrics so we can trigger alerts if needs be e.g. if we come here having processed no volumes and log a total volumes
# metric of zero we can set an alert to look out for zero counters.
metrics_and_exit() {
  exitcode=${1:-99}

  now=$(/bin/date '+%s')
  echo "${metricpath}.volumes_total ${volumes_total} ${now}" | /bin/nc -q0 -w 60 ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${metricpath}.volumes_total ${volumes_total} ${now}"

  echo "${metricpath}.volumes_failed ${volumes_failed} ${now}" | /bin/nc -q0 -w 60 ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${metricpath}.volumes_failed ${volumes_failed} ${now}"

  echo "${metricpath}.volumes_success ${volumes_success} ${now}" | /bin/nc -q0 -w 60 ${MONITORING_HOST} ${MONITORING_PORT}
  log "Sending metric: ${metricpath}.volumes_success ${volumes_success} ${now}"

  exit ${exitcode}

}

# Log some runtime details
log "Running in ${runmode} mode"
log "Recording to metric path ${metricpath}"
log "Logging metrics to ${MONITORING_HOST}:${MONITORING_PORT}"
log "Snapshots are retained for ${retention_days} days"

# Setup logging and make sure we have everything we need
log_setup
prerequisite_check

# Single mode: Just process the volumes for the instance I'm running on
# Discover: Go find all the instances you can and process the volumes they have
if [ "${runmode}" == "single" ]; then
  volume_list=$(get_volumes $instance_id)
  snapshot_volumes $volume_list
  cleanup_snapshots $volume_list
elif [ "${runmode}" == "discover" ]; then
  instance_ids=$(aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
  for id in $instance_ids; do
    volume_list=$(get_volumes $id)
    snapshot_volumes $volume_list
    cleanup_snapshots $volume_list
  done
fi

# All done 
metrics_and_exit 0

exit # should never get here
