#!/usr/bin/env python

import os
import argparse
from subprocess import call

admin_username = 'admin'
admin_password = os.environ['MONGO_ADMIN_PASSWORD']

parser=argparse.ArgumentParser()
parser.add_argument("-d", "--db-name", help="the DB to create the user in", required=True)
parser.add_argument("-u", "--username", help="the name of the user to create", required=True)
parser.add_argument("-p", "--password", help="the password for the user", required=True)
parser.add_argument("-r", "--role", help="the permissions for the user on the DB", default='readWrite')
args = parser.parse_args()

user_create_js = "db.getSiblingDB('" + args.db_name + "').createUser({user: '" + args.username + "', pwd: '" + args.password + "', roles: [ { role: '" + args.role + "', db: '" + args.db_name + "'}] } );"

print 'Creating user'
call(["/usr/bin/mongo","admin","-u",admin_username,"-p",admin_password,"--authenticationDatabase","admin","--eval",user_create_js])
