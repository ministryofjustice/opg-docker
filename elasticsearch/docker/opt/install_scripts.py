#!/usr/bin/env python

import os
import sys
import time
import subprocess
from __builtin__ import any
from ast import literal_eval
import requests
import json
from datetime import datetime


if os.getenv('SHARED_DATA_BASE') and os.getenv('SHARED_DATA_PATHS'):

    es_running = "run: elasticsearch: (pid"
    es_host = os.environ.get('ELASTICSEARCH_HOST', 'localhost')
    es_port = os.environ.get('ELASTICSEARCH_PORT', '9200')
    es_kibana_index = os.environ.get('KIBANA_INDEX', '.kibana')
    request_url = "http://{}:{}".format(es_host, es_port)

    sleep_timeout = float(os.environ.get('DASHBOARD_SLEEP_TIMEOUT', 120))

    logfile = open("/var/log/elastic-scripts.log", "w")
    sys.stdout = logfile
    sys.stderr = logfile
else:
    print "Beats installation not initialised, skipping"


def log_message(message, message_type="info"):
    output = {
        "type": "log",
        "@timestamp": "{}".format(datetime.today().isoformat()),
        "tags": "[{}]".format(message_type),
        "message": "{}".format(message)
    }
    print "{}".format(json.dumps(output))


def find_and_install_scripts():
    for path in data_paths:
        scripts = find_scripts("{}{}".format(os.getenv('SHARED_DATA_BASE'), path))
        if scripts is not None and len(scripts):
            install_scripts(scripts)


def install_scripts(scripts):

    for script_path in scripts:
        log_message("Loading {}".format(script_path))

        payload = json.load(open(script_path))
        headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8'}
        file_data = script_path.split('/')
        name = file_data.pop().replace('.json', '')
        target = file_data.pop()

        if 'title' in payload and target == 'index-pattern':
            name = payload['title']

        r = requests.put("{}/{}/{}/{}".format(request_url, es_kibana_index, target, name),
                         data=json.dumps(payload),
                         headers=headers)

        log_message(r.text)


def find_scripts(directory='', extension='.json'):
    if os.path.exists(directory):
        scripts = []

        for root, sub_dir, file_list in os.walk(directory):
            for file_name in file_list:
                if file_name.endswith(extension):
                    scripts.append(os.path.join(root, file_name))

        return scripts


def create_default_indices():
    log_message("Creating default indices")
    headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8'}
    r = requests.put("{}/{}".format(request_url, es_kibana_index), headers=headers)
    log_message(r.text)
    data = '{"search": {"properties": {"hits": {"type": "integer"}, "version": {"type": "integer"}}}}'
    r = requests.put("{}/{}/_mapping/search".format(request_url, es_kibana_index), headers=headers, data=data)
    log_message(r.text)

try:
    data_paths = literal_eval(os.getenv('SHARED_DATA_PATHS'))
except ValueError:
    log_message("Could not parse script paths from the environment", "critical")
    exit(1)

# We sit and poll to see if elastic search has started, if not, wait 30 seconds and try again
while True:
    log_message("Elastic search has not started, waiting.")
    time.sleep(30)
    res = subprocess.Popen(["/usr/bin/sv", "status", "elasticsearch"], stdout=subprocess.PIPE)

    if any(es_running in item for item in res.stdout.readlines()):
        log_message("Elastic search is running")
        log_message("Waiting {} seconds for indices to be created".format(sleep_timeout))
        time.sleep(sleep_timeout)
        create_default_indices()
        find_and_install_scripts()
        logfile.close()
        exit(0)
