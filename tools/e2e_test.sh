#!/bin/bash
set -ex

stechec2_run=$1
config_yml=$2
expected_results=$3

# Run match
"$stechec2_run" --quiet "$config_yml" > actual_results

# Compare results
diff -Naur "$expected_results" actual_results
