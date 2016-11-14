# fake-sqs container

Ruby gem run as a service to emulate an AWS SQS queue.

Use environment variable `FAKE_SQS_QUEUENAME` to set a queue name to be created on container boot/start. If the variable is unset then
no queue is created (but the service is still started).

For example:

```
$ docker run -p 4568:4568 -e FAKE_SQS_QUEUENAME=myqueue -itd registry.service.opg.digital/opguk/fake-sqs:latest
d1c4c6c1e6e426252c1badc448111e4a9f4d90f96bb26610c01fd077228c0062

$ docker logs $(docker ps -q) | tail -10
<CreateQueueResponse>
    <CreateQueueResult>
        <QueueUrl>http://0.0.0.0:4568/myqueue</QueueUrl>
    </CreateQueueResult>
    <ResponseMetadata>
        <RequestId>8de08b27-4ebf-45e7-af57-d6b1d8e03199</RequestId>
    </ResponseMetadata>
</CreateQueueResponse>
localhost - - [19/Nov/2015:16:37:05 UTC] "POST / HTTP/1.1" 200 266
- -> /
$
```
