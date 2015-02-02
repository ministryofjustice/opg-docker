Development use only
a lightweight implementation of logging stack
purposely nonpersistent

I.e. all processes are running as root.


Components:
- redis (input queue) (exposed on port 6379)
- logstash (exposed as syslog listener on port 514)
- elasticsearch (embedded) (exposed on port 9200)
- kibana (embedded) (exposed on port 80)
