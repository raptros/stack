#!/usr/bin/env bash
set -xe
#@@@ DONE: "$(dirname "$0")/with-vagrant.sh" debian-7-amd64 "$* release"
#@@@ DONE: "$(dirname "$0")/with-vagrant.sh" alpine-3.6-x86_64 "--binary-variant=static --static $* upload"
"$(dirname "$0")/with-vagrant.sh" freebsd-11.0-amd64 "$* upload" "export LANG=en_US.UTF-8;"
"$(dirname "$0")/with-vagrant.sh" centos-6-x86_64 "--binary-variant=gmp4 $* upload"
"$(dirname "$0")/with-vagrant.sh" debian-7-i386 "$* upload"
"$(dirname "$0")/with-vagrant.sh" centos-6-i386 "--binary-variant=gmp4 $* upload"
