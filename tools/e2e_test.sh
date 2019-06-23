#!/bin/bash

set -x
set -e

stechec2_server="$1" && shift
stechec2_client="$1" && shift
rules="$1" && shift
expected="$1" && shift
declare -a champions
champions=($@)

declare -a pids
$stechec2_server --rep_addr ipc://reqrep --pub_addr ipc://pubsub --rules $rules --verbose 0 --nb_clients ${#champions[@]} > actual.log &
pids+=($!)
for i in ${!champions[@]}; do
  $stechec2_client --req_addr ipc://reqrep --sub_addr ipc://pubsub --rules $rules --verbose 0 --champion ${champions[$i]} --client_id $((i+1)) --name client-$((i+1)) &
  pids+=($!)
done

echo Waiting...
wait ${pids[@]}

diff -Naur actual.log $expected
