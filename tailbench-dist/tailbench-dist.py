#!/usr/bin/env python

import os
import sys
import getopt
import json
import subprocess
import time
import datetime
import numpy as np
from mpi4py import MPI

##### Helper to get monotonic time ######
__all__ = ["monotonic_time"]

import ctypes, os

CLOCK_MONOTONIC_RAW = 4 # see <linux/time.h>

class timespec(ctypes.Structure):
    _fields_ = [
        ('tv_sec', ctypes.c_long),
        ('tv_nsec', ctypes.c_long)
    ]

librt = ctypes.CDLL('librt.so.1', use_errno=True)
clock_gettime = librt.clock_gettime
clock_gettime.argtypes = [ctypes.c_int, ctypes.POINTER(timespec)]

def monotonic_time_ns():
    t = timespec()
    if clock_gettime(CLOCK_MONOTONIC_RAW , ctypes.pointer(t)) != 0:
        errno_ = ctypes.get_errno()
        raise OSError(errno_, os.strerror(errno_))
    return (t.tv_sec * 1e9) + t.tv_nsec

###### End time stuff #########

# Defaults that can be overridden by json file
TBENCH_SERVER_ENV = {
    "TBENCH_WARMUPREQS" : 1000,
    "TBENCH_MAXREQS"    : 10000
}

TBENCH_CLIENT_ENV = {
    "TBENCH_QPS"        : 500,
    "TBENCH_MINSLEEPNS" : 10000,
    "TBENCH_RANDSEED"   : 1234
}

def usage(argv, exit=None, out_f=sys.stderr):
    print >> out_f, "Usage: %s [OPTIONS] <config.json>" % argv[0]
    print >> out_f, "   -h (--help)          : print help and exit"
    print >> out_f, "   -i (--iterations=)   : number of iterations"
    print >> out_f, "   -o (--output-fname=) : name of output file"

    if exit is not None:
        sys.exit(exit)

def parse_cmd_line(argc, argv, envp):
    opts = []
    args = []
    iters = 100
    out_fname = "output.csv"

    try:
        opts, args = getopt.getopt(argv[1:],
            "hi:o:", ["help", "iterations=", "output-fname="]
        )
    except getopt.GetoptError, err:
        print >> sys.stderr, "Error parsing options: %s" % err
        usage(argv, exit=1)

    for o, a in opts:
        if o in ("-h", "--help"):
            usage(argv, exit=0, out_f=sys.stdout)

        elif o in ("-i", "--iterations"):
            iters = int(a)

        elif o in ("-o", "--output-fname"):
            out_fname = a

    if len(args) != 1:
        print >> sys.stderr, "Error parsing command line: no JSON file given"
        usage(argv, exit=1)

    return args[0], iters, out_fname
        
def parse_json(json_file):
    try:
        with open(json_file, "r") as f:
            config_data = json.load(f)

    except IOError as e:
        print >> sys.stderr, "%s" % e
        return None

    except ValueError as e:
        print >> sys.stderr, "Error parsing %s: %s" % (json_file, e)
        return None

    # Required stuff
    for req in ("server", "client"):
        if req not in config_data:
            print >> sys.stderr, "'%s' entry not found in %s" % (req, json_file)
            return None

        for req2 in ("exe", "argv", "envp"):
            if req2 not in config_data[req]:
                print >> sys.stderr, "'%s' entry not found in %s['%s']" % (req2, json_file, req)
                return None

    return config_data

def update_env_val(key, val):
    if key in os.environ:
        return val + ':' + os.environ[key]

    return val

def start_server(config_data):
    server_data = config_data["server"]

    _exe = server_data["exe"]
    _argv = server_data["argv"]
    _envp = server_data["envp"]

    # parse the user provided env, overriding defaults if present
    for e in _envp:
        TBENCH_SERVER_ENV[e] = update_env_val(e, _envp[e])

    envp = {env : str(TBENCH_SERVER_ENV[env]) for env in TBENCH_SERVER_ENV}

    # executable
    cmd = []
    cmd += ["%s%s" % (
        config_data["path"] + "/" if ("path" in config_data and _exe[0] != '/') else '', _exe
    )]

    # argv
    for arg in _argv:
        cmd += ["%s" % arg]

    server_p = subprocess.Popen(cmd, env=envp, shell=False, cwd=config_data['path'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    return server_p

def start_client(config_data):
    client_data = config_data["client"]

    _exe = client_data["exe"]
    _argv = client_data["argv"]
    _envp = client_data["envp"]

    # parse the user provided env, overriding defaults if present
    for e in _envp:
        TBENCH_CLIENT_ENV[e] = update_env_val(e, _envp[e])

    # stringify
    envp = {env : str(TBENCH_CLIENT_ENV[env]) for env in TBENCH_CLIENT_ENV}

    # executable
    cmd = []
    cmd += ["%s%s" % (
	config_data["path"] + "/" if ("path" in config_data and _exe[0] != '/') else '', _exe
    )]

    # argv
    for arg in _argv:
        cmd += ["%s" % arg]

    client_p = subprocess.Popen(cmd, env=envp, shell=False, cwd=config_data['path'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    return client_p

def timestamp():
    return int(monotonic_time_ns() / 1000)

def gather_iter_runtimes(comm, rank, size, runtime):
    senddata = runtime
    recvdata = None

    if size == 1:
        return [senddata]

    if rank == 0:
        recvdata = np.arange(size)

    return comm.gather(senddata, root=0)

def main(argc, argv, envp):
    json_file, iters, out_fname = parse_cmd_line(argc, argv, envp)
    runtime_dat = {}

    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    # parse json
    config_data = parse_json(json_file)
    if config_data is None:
        return 2

    for i in range(iters):
        server_p = start_server(config_data)

        # give server 3s to come up
        time.sleep(3)

        comm.Barrier()

        ts = timestamp()
        client_p = start_client(config_data)

        st = client_p.wait()
        te = timestamp()
        if st != 0:
            print "Client exited with nonzero status %d" % st

        st = server_p.wait()
        if st != 0:
            print "Server exited with nonzero status %d" % st

        runtimes = gather_iter_runtimes(comm, rank, size, te-ts)

        if rank == 0:
            runtime_dat[i] = runtimes
            print "Iteration %d finished" % i

    if rank == 0:
        with open(out_fname, "w") as f:
            print >> f, "iteration,rank,runtime_microseconds"
            for i in range(iters):
                for r in range(size):
                    print >> f, "%d,%d,%d" % (
                        i, r, runtime_dat[i][r]
                    )

    return 0

if __name__ == '__main__':
    argv = sys.argv
    argc = len(argv)
    envp = os.environ

    sys.exit(main(argc, argv, envp))
