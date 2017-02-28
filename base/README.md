# opguk/base

Base docker image that:

- ensures latest ubuntu
- creates application skeleton
- creates log shipping skeleton
- ensures we have a unique self signed certificate available

## Structure

Directory structure:

```
/etc/my_init.d - all scripts within will be executed at boot
/app - directory to install app (owned by app user)
/data - directory to store data (might be available as a mounted volume)
/var/run/app - for pid/sock files
/var/log/app - for all application logs
```

## /etc/my_init.d

Init process ensures that all scripts within `/etc/my_init.d` will be executed at container start.

If you enter container through docker run your_script, you will skip the init script. In such case it's the best to run all cscripts with `run-parts --test /etc/my_init.d`

## Log shipping

It ships logs using beaver that will only start if:

- monitoring box is linked (monitoring `hostname` is available in /etc/hosts)
- or variable `MONITORING_ENABLED` is set.

Logs are shipped to redis on `monitoring` host.

All inheriting containers should add their respective beaver config file to `/etc/beaver.d/(change_me).conf`

## Versions

Versions are in reduced semver (because docker don't support build segment): i.e: `opg/base:0.0.2`

If `OPG_DOCKER_TAG` env variable will be passed to the container then it will generate `/app/META` file with `{'rev': '$OPG_DOCKER_TAG'}`

## Supported variables

- OPG_DOCKER_TAG - see versions
- SKIP_SSL_GENERATE - when set container will not create self signed certificate on start
- OPG_BASE_SSL_CERT - pass a cert as a multiline or using `"\n"`
- OPG_BASE_SSL_KEY - pass a key as a multiline or using `"\n"`

## Docker task wrapper

The script `/scripts/base/docker-task-wrapper.sh` is designed to be used when using the base image (or any image inheriting `base`) with `docker-compose` to run a docker based task. The script will manage the execution of the task passed to it and send status events to Sensu to raise alerts and keep track of recurring events using a TTL (Dead Man's Switch) timer. Useful for making sure a job runs regularly for example.

The script takes the first parameter as a task name (so it should be unique) which is used in the event raised to Sensu (so future updates to this event should be tracked and reported using the same task name). The remaining parameters are assumed to be a command string so are simply executed and the exit code checked and reported on.

Any tasks invoked through this wrapper must:

- Return exit codes in line with Sensu event code standards (<https://sensuapp.org/docs/latest/getting-started-with-checks>)

- Return a single line of output. For multi-line output (e.g scripts that you cannot control the output of) the last line of the output is taken. Any other lines are discarded along with CR/LF. Stderr is captured in case it's the only output.

Variables that can override the defaults used by the script:

- SENSU_PORT (TCP port of the Sensu client the wrapper reports to)
- SENSU_TTL (Time To Live (in seconds) applied to the event timer)
- STATSD_HOST (Hostname of the host capturing statsd data)
- STATSD_PORT (Port on the StatsD host listening)
- STATSD_METRICPATH (Prefix for StatsD Metrics sent off)

Variables that the wrapper exports to be used by tasks called:

- DOCKER_GATEWAY (IP address of default gateway (useful inside docker to talk to host based ports))

Variables that can be used to define custom StatsD metrics:

By default the wrapper script will send the exit code and elapsed time (in seconds) of the task to StatsD. You can define custom metrics using variables in the format:

- STATSD_METRIC_metricname

where `metricname` is the name of the metric to pass to StatsD and the value of the variable is a command to be evaluated by the script (evaluated so variable contents can be exposed and parsed).

For example, to look through the output from an `aws s3 sync` task wrapped by this script, and count up the number of files copied and send that value as a metric called `filessyncd` in your `docker-compose` `env` file you would define:

`STATSD_METRIC_filessyncd=echo "$TASKOUTPUT" | cat -vet | grep -ci 'copy:.*s3:'`

You can define zero or more custom metrics this way.

## CFSSL

CFSSL binaries are installed. On startup the container will run these scripts.

1. 90-cfssl-gencert: Generate container's own certificate and try to remote sign it with the CA.
2. 91-cfssl-cacert: Download and install the CA public cert from the CA.

It can be controlled via the following variables.

`SKIP_SSL_GENERATE` - If set will skip generation of the SSL cert

`OPG_BASE_CA_PROFILE` - The profile to communicate with the CA, the type of certificate signing and the cert filename. Choices are `client` or `server`.

`OPG_BASE_CSR_CN` - The `common name` attribute of the certificate.

`OPG_BASE_CSR_HOSTS` - Comma separated list of hostnames to add to the certificates `SAN` field

`OPG_BASE_DOMAIN`- The base domain that is added to the hostname. Allows the cert to contain it's own container FQDN in the SAN field of the cert.

Example config.

```
SKIP_SSL_GENERATE
OPG_BASE_CA_PROFILE=server
OPG_BASE_CSR_CN=front.qa.internal
OPG_BASE_CSR_HOSTS=client.alta.com,client.altb.com
OPG_BASE_DOMAIN=qa.internal
```

## TODO

- Configure syslog shipping
- Solve logrotation as we don't want dockers to leak disk usage
