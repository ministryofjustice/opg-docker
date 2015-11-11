#!/bin/bash
#
# A simple wrapper script designed to wrap around tasks invoked through docker-compose and report event status to Sensu via API
#
# Any tasks invoked through this wrapper must:
#
# 1. Return exit codes in line with Sensu event code standards (https://sensuapp.org/docs/latest/getting-started-with-checks)
# 2. Return a single line of output. For multi-line output (e.g scripts that you cannot control the output of) the last line of
#    the output is taken. Any other lines are discarded along with CR/LF. Stderr is captured in case it's the only output.
#
# See usage() for how to call this script
#
# Uses the following environment variables (using sensible defaults if not set):
#
# SENSU_PORT                      (tcp port to reach Sensu API)
# SENSU_TTL                       (ttl on Sensu events sent (in seconds))
#

# Set defaults
#
SENSU_PORT=${SENSU_PORT:-3030}
SENSU_TTL=${SENSU_TTL:-86400}

# Functions
#

# Tell me how to use this script
usage() {
  echo "Usage: ${SCRIPTNAME} task_name command_string"
  echo ""
  echo "task_name:      Unique task identifier used in Sensu alert raised"
  echo "command_string: Command plus arguments to execute"
  echo ""
  echo "e.g. ${SCRIPTNAME} backup_tmp tar -cvf /var/tmp/tmp.tar /tmp"
  return
}

# Get gateway IP address (used if inside docker to contact exposed host ports). Use localhost if for some reason we can't 
# work out the default gateway
function get_gateway_ip() {

  IP=$(/sbin/ip route \
      | /usr/bin/awk '/default.*via/ {print $3}' \
      | /usr/bin/tr -d ' ')

  if [[ -z "${IP}" ]] ; then
    IP="localhost"
  fi

  echo "${IP}"

}

# Report to Sensu on how we did
report_and_exit() {
  TASKNAME="${TASKNAME:-${SCRIPTNAME}}"
  EXITCODE="${1:-3}"

# Print out what we saw from the task we ran before we process it and strip out excess lines
  echo "${TASKOUTPUT}"

  TASKOUTPUT=$(echo "${TASKOUTPUT}" \
                | /usr/bin/tail -1 \
                | /usr/bin/tr -d '\n\r{}' \
                | /usr/bin/tr -s ' \t')

  echo '{"name": "'"${TASKNAME}"'", "ttl": '"${SENSU_TTL}"', "output": "'"${TASKOUTPUT}"'", "status": '"${EXITCODE}"'}' | ${NC} "${DOCKER_GATEWAY}" "${SENSU_PORT}"

  exit "${EXITCODE}"
}

# Define other variables
#
NUMARGS=${#}
ARGS=(${*})
SCRIPTNAME=$(echo "$(/usr/bin/basename ${0})")
NC="/bin/nc -q0 -w 60"
DOCKER_GATEWAY="$(get_gateway_ip)"
TASKNAME=${ARGS[0]:-${SCRIPTNAME}}
shift
ARGS=${*}

# Export variables which may be of use to the task we execute later
#
export DOCKER_GATEWAY

# Make sure we have enough to get on with and if not
# just exit (don't bother reporting to Sensu)
#
if [[ ${NUMARGS} -lt 2 ]] ; then
  usage
  exit 99
fi

# Main
#
echo "(${SCRIPTNAME}) Initiating task: ${TASKNAME}"
echo "(${SCRIPTNAME}) Calling: ${*}"

# Execute the request and save the exit code and output (redirect stderr in case that's the only output)
#
TASKOUTPUT=$(eval ${*} 2>&1)
TASKRC=${?}

# Handle errors
#
if [[ ${TASKRC} -ne 0 ]] ; then
  echo "Error ${TASKRC} from task execution"
  if [[ ${TASKRC} -gt 3 ]] ; then
    TASKRC=3
  fi
  report_and_exit ${TASKRC}
else
  report_and_exit 0
fi

report_and_exit 3 # Should never get here
