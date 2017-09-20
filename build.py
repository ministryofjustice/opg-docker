from multiprocessing import Pool
from time import sleep
from datetime import datetime
import os
import sys
from functools import partial

import subprocess

def docker_build(docker_img, _):
    cmd = ['docker',
           'build',
           '-t',
           docker_img,
           '.']

    start = datetime.now()
    pipes = subprocess.Popen(cmd,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE,
                             cwd=docker_img,
                             shell=False)

    std_out, std_err = pipes.communicate()
    end = datetime.now()

    duration = end - start

    # add time it took to build this image
    return (docker_img, pipes.returncode, std_out, std_err, start, end, duration)



def build_batch_of_docker_images(image_list, concurrency):
    pool = Pool(processes=concurrency)

    results = []

    for build in image_list:
        results.append(pool.map_async(partial(docker_build, build), [1]))

    pool.close()
    pool.join()

    print_build_results(results)
    retry_failed_jobs(results)

    return results


def print_build_results(results, detail=False):
    for result in results:

        image, rc, stdout, stderr, start, end, duration  =  result.get()[0]
        print "build job for %s started at %s and took %s terminating with an exit code %s" % (image, start, duration, rc )
        if detail:
            print "stdout for job %s:" % image
            print stdout
            print "stderr for job %s:" % image
            print stderr



def retry_failed_jobs(results):
# retry any failures here
    for result in results:
        image, rc, stdout, stderr, start, end, duration  =  result.get()[0]

        if rc != 0:
            print "retrying failed job %s" % image
            docker_build(image, False)
            print_build_results([ result ], detail=False)


def measure_overall_sucess(results):
    failures = 0

    for result in results:
        image, rc, stdout, stderr, start, end, duration  =  result.get()[0]

        if rc != 0:
            failures = failures + 1
            print_build_results([ result ], detail=True)
    return failures



# build the batch and abort on any build failure

batch = sys.argv[1:]
print "starting build.py with params: %s" % batch

results = build_batch_of_docker_images(batch, len(batch))
if measure_overall_sucess(results) != 0:
    sys.exit(1)

