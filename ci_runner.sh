#!/bin/bash

# crontab example :
#
# 22 15 * * * jmettraux cd /home/jmettraux/ci && ./ci_runner.sh ci_ruote.rb

source /home/jmettraux/.rvm/scripts/rvm
ruby $1

