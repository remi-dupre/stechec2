#!/bin/bash

set -ex

stechec2_run=$1
config_yml=$2

"$stechec2_run" "$config_yml"
