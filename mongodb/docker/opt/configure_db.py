#!/usr/bin/env python

import os
import time
from subprocess import call

import sys
import socket

if os.getenv('SKIP_SETUP','False') == 'True':
  print "SKIP_SETUP is set to True - exiting"
  sys.exit()

host_ip = os.environ['HOST_IP'].replace("['","").replace("']","")
rs_hosts = os.environ['MONGO_RS_HOSTS'].split(',')
admin_username = 'admin'
admin_password = os.environ['MONGO_ADMIN_PASSWORD']

if host_ip != socket.getaddrinfo(rs_hosts[0],80)[0][4][0]:
  print 'Doing nothing - only the first listed node should try to initiate replicate set'
  exit(0)

print "Waiting 1 minute to allow all nodes time to come up"
time.sleep(60)

with open("/etc/hosts", "a") as myfile:
  myfile.write("127.0.0.1 " + rs_hosts[0])

id_number = 0
rs_initiate_js = "rs.initiate({'_id': 'rs0' , 'members': ["
for rs_host in rs_hosts:
  rs_initiate_js = rs_initiate_js + "{ '_id': " + str(id_number) + ", 'host': '" + rs_host + ":27017'},"
  id_number += 1
rs_initiate_js += "]});"

admin_create_js = "db.createUser({user: 'admin', pwd: '" + admin_password + "', roles: [ 'root', 'userAdminAnyDatabase' ]});"

wait_for_master_js = "while(db.isMaster().ismaster != true){}"

print 'Setting up replica set'
call(["/usr/bin/mongo","admin","--eval",rs_initiate_js])
print 'Waiting to become master'
call(["/usr/bin/mongo","admin","--eval",wait_for_master_js])
print 'Creating admin user'
call(["/usr/bin/mongo","admin","--eval",admin_create_js])

readFile = open("/etc/hosts")
lines = readFile.readlines()
readFile.close()
w = open("/etc/hosts",'w')
w.writelines([item for item in lines[:-1]])
w.close()

suffix=1
while os.getenv('MONGO_USER_' + str(suffix),'None') != 'None':
  user_create_params = os.getenv('MONGO_USER_' + str(suffix)).split('|')
  call(["/opt/create_user.py","-d",user_create_params[0],"-u",user_create_params[1],"-p",user_create_params[2],"-r",user_create_params[3]])
  suffix += 1

suffix=1
while os.getenv('MONGO_INDEX_' + str(suffix),'None') != 'None':
  index_create_params = os.getenv('MONGO_INDEX_' + str(suffix)).split('|')
  call(["/opt/reindex_database.py","-d",index_create_params[0],"-c",index_create_params[1],"-i",index_create_params[2]])
  suffix += 1

