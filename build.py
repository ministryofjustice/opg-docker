""" build.py """

import subprocess
import sys
from datetime import datetime
from functools import partial
from multiprocessing import Pool


def docker_build(docker_img, _):
    """ calls `make` and returns the result """
    cmd = ['make']

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
    return (
        docker_img,
        pipes.returncode,
        std_out,
        std_err,
        start,
        end,
        duration
    )


def build_batch_of_docker_images(image_list, concurrency):
    """ builds a list of docker images in parallel """
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
    """ prints out the build results and timings """

    for result in results:
        image, returncode, stdout, stderr, start, _, duration = result.get()[0]
        print(
            'build job for %s started at %s and took %s '
            'terminating with an exit code %s' % (image,
                                                  start,
                                                  duration,
                                                  returncode)
        )
        if detail:
            print "stdout for job %s:" % image
            print stdout
            print "stderr for job %s:" % image
            print stderr


def retry_failed_jobs(results):
    """ retries any failed job contained in 'results' """
    for result in results:
        image, returncode, _, _, _, _, _ = result.get()[0]

        if returncode != 0:
            print "retrying failed job %s" % image
            docker_build(image, False)
            print_build_results([result], detail=False)


def measure_overall_sucess(results):
    """ returns number of failures """
    failures = 0

    for result in results:
        _, returncode, _, _, _, _, _ = result.get()[0]

        if returncode != 0:
            failures = failures + 1
            print_build_results([result], detail=True)
    return failures


# build the batch and abort on any build failure
BATCH = sys.argv[1:]
print "starting build.py with params: %s" % BATCH

# with a maximum of 8 containers in parallel
BUILD_RESULTS = build_batch_of_docker_images(BATCH, 8)
if measure_overall_sucess(BUILD_RESULTS) != 0:
    sys.exit(1)
