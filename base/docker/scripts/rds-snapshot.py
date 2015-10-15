#!/usr/bin/env python
"""
Backup Amazon RDS DBs.

Script is expected to be run on EC2 VM within the same Amazon account as RDS.
Script reads tags of EC2 and then searches for all matching RDSes.
Where matching RDS is the one that shares the same "Stack" tag value.
"""

import sys
import time
import argparse

import boto
import boto.utils
import boto.ec2
import boto.rds2


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--stack-tag', help="name of tag shared by EC2 and RDS", default="Stack")
    parser.add_argument('--dry-run', help="skip backup", action='store_true')
    args = parser.parse_args()


    region = boto.utils.get_instance_metadata()['placement']['availability-zone'][:-1]
    print "region: {}".format(region)
    instance_id = boto.utils.get_instance_metadata()['instance-id']
    print "instance_id: {}".format(instance_id)
    account_id = boto.utils.get_instance_metadata()['iam']['info']['InstanceProfileArn'].split(':')[4]
    print "account_id: {}".format(account_id)

    conn_ec2 = boto.ec2.connect_to_region(region)
    conn_rds = boto.rds2.connect_to_region(region)


    my_instance = conn_ec2.get_all_instances(instance_ids=[instance_id])[0].instances[0]

    if args.stack_tag not in my_instance.tags:
        print "Missing tag '{}' on this EC2".format(args.stack_tag)
        return 1
    my_stack = my_instance.tags[args.stack_tag]
    print "Tag {}:{}".format(args.stack_tag, my_stack)
    print

    db_descriptions = conn_rds.describe_db_instances()[u'DescribeDBInstancesResponse'][u'DescribeDBInstancesResult'][u'DBInstances']
    ts_formatted = "-".join(str(time.time()).split('.'))

    error_count = 0

    for db_desc in db_descriptions:
        rds_id = db_desc['DBInstanceIdentifier']

        # For now AWS API does not support filtering filters={'tag:{}'.format(STACK_TAG):my_stack,}
        # see: http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_DescribeDBInstances.html
        # so we have to go through list_tags_for_resource(arn)
        rds_arn = 'arn:aws:rds:{region}:{account_id}:db:{rds_id}'.format(
            region=region,
            account_id=account_id,
            rds_id=rds_id
        )
        tag_list = conn_rds.list_tags_for_resource(rds_arn)['ListTagsForResourceResponse']['ListTagsForResourceResult']['TagList']
        tag_dict = dict(map(lambda x: (x['Key'], x['Value']), tag_list))
        if args.stack_tag not in tag_dict:
            print "Skipping {} as missing tag '{}'".format(rds_id, args.stack_tag)
        elif tag_dict[args.stack_tag] != my_stack:
            print "Skipping {} as tag '{}'!='{}'".format(rds_id, tag_dict[args.stack_tag], my_stack)
        else:
            snapshot_id = '{}-{}'.format(rds_id, ts_formatted)
            if args.dry_run:
                print "Backing up {} as {} - dry run".format(rds_id, snapshot_id)
            else:
                print "Backing up {} as {} - requested".format(rds_id, snapshot_id)
                try:
                    conn_rds.create_db_snapshot(snapshot_id, rds_id)
                except boto.rds2.exceptions.InvalidDBInstanceState as e:
                    error_count += 1
                    print "Failed - API response: {}".format(e.body)

        return error_count


if __name__ == "__main__":
    error_count = main()
    sys.exit(error_count)
