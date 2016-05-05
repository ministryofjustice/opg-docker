#!/usr/bin/env python

import os
from subprocess import call

admin_username = 'admin'
admin_password = os.environ['MONGO_ADMIN_PASSWORD']

status_js = "result = rs.status(); printjson(result);"

print 'Checking status'
call(["/usr/bin/mongo","admin","-u",admin_username,"-p",admin_password,"--authenticationDatabase","admin","--eval",status_js])
