#!/bin/bash -eu

# This script signals ngnix to reconfigure using SIGHUP signal.
# Signaling is the way to update rotated certificates without
# downtime, see:  http://nginx.org/en/docs/control.html#reconfiguration.
# This assumes the current process shares the process namespace of ngnix.
# If running as a side container, it requires SYS_PTRACE capability,
# and shareProcessNamespace: true`, see here:
# https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/

function loginfo() {
    printf "%s %s\n" "$(date +'%Y/%m/%d %H:%M:%S')" "$@"
}

# This function gets the PID of ngnix master and signals
# a reload with a SIGHUP. If the PID is not found it waits
# till it finds it.
function signal_nginx() {
    result=`ps aux`
    nginxPID=`echo "$result"|grep "nginx: master process"| awk '{print $2}'|head -1`
    loginfo "Signaling  PID $nginxPID..."
    while [ -z "$nginxPID" ];
    do
        loginfo "PID not found, waiting..."
        sleep 2
        result=`ps aux`
        nginxPID=`echo "$result"|grep "nginx: master"| awk '{print $2}'`
        loginfo "Nginx PID: $nginxPID"
    done 
    # grep and sends SIGHUP to nginx: master
    sudo kill -HUP "$nginxPID"
    loginfo "Reloaded"  
}

function main() {
    # Subscribe to signal USR1
    trap 'signal_nginx' USR1
    
    # Because the script is executed on first rotation
    # the nginx needs to be signaled
    signal_nginx

    # Spawn a dummy child process asynchroniously to
    # be able to wait.
    sleep infinity & PID=$! 
    while :
    do
        loginfo "Waiting for next reload signal..."
        # Wait blocks till a signal comes.
        # The `|| true` is needed to prevent the script to exit with error
        # becuase on a a kill signal like SIGUSR1, ´wait´ exits with error.
        wait || true
done
}

main
