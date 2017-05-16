#!/usr/bin/env python

import os
import argparse
from subprocess import call

admin_username = 'admin'
admin_password = os.environ['MONGO_ADMIN_PASSWORD']

parser=argparse.ArgumentParser()
parser.add_argument("-f", "--backup-files", help="the files to restore the DB from", required=True, nargs='+')

args = parser.parse_args()

for backup_file in args.backup_files:
	print 'Restoring from "' + backup_file + '"'
        call(["/usr/bin/mongorestore","admin","-u",admin_username,"-p",admin_password,backup_file])
