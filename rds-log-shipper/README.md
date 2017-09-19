A container to retrieve and forward RDS logs to redis through beaver.

Example docker-compose file and variables:

```
rdslog:
  build: .
  environment:
  - OPG_RDSTAIL_INSTANCE=opgcoreapi-feature
  - AWS_REGION=eu-west-1
  - MONITORING_ENABLED=yes
```

