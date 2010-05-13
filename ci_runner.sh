#!/bin/bash

# crontab example :
#
# 22 15 * * * jmettraux cd /home/jmettraux/ci && ./ci_runner.sh ruote_ci.rb

source /home/jmettraux/.rvm/scripts/rvm
ruby $1

