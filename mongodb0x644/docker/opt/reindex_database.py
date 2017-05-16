#!/usr/bin/env python

import os
import argparse
from subprocess import call

admin_username = 'admin'
admin_password = os.environ['MONGO_ADMIN_PASSWORD']

parser=argparse.ArgumentParser()
parser.add_argument("-d", "--db-name", help="the DB to create the user in", required=True)
parser.add_argument("-c", "--collection", help="the collection to index", required=True)
parser.add_argument("-i", "--index-definition", help="the index definition", required=True)

args = parser.parse_args()

reindex_js = "db.getSiblingDB('" + args.db_name + "').getCollection('" + args.collection + "').ensureIndex( " + args.index_definition + " );"

print 'Creating index'
call(["/usr/bin/mongo","admin","-u",admin_username,"-p",admin_password,"--authenticationDatabase","admin","--eval",reindex_js])
