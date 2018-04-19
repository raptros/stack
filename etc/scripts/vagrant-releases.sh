#!/usr/bin/env bash
set -xe
#@@@ DONE "$(dirname "$0")/with-vagrant.sh" debian-7-amd64 "$* release"
"$(dirname "$0")/with-vagrant.sh" centos-6-x86_64 "--binary-variant=gmp4 $* upload"
"$(dirname "$0")/with-vagrant.sh" freebsd-11.0-amd64 "$* upload" "export LANG=en_US.UTF-8;"
"$(dirname "$0")/with-vagrant.sh" debian-7-i386 "$* upload"
#@@@ NO GHC 8.2.2 BINDISTS FOR LINUX-32-GMP4, SO DISABLE "$(dirname "$0")/with-vagrant.sh" centos-6-i386 "--binary-variant=gmp4 $* upload"
#@@@ REMOVE ALPINE? "$(dirname "$0")/with-vagrant.sh" alpine-3.6-x86_64 "--binary-variant=static --static $* upload"
