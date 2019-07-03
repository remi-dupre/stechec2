#!/bin/bash

set -x
set -e

diff -Naur "$1" "$2"
