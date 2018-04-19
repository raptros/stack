#!/usr/bin/env bash
#TODO: move this logic into release.hs.
set -xe
#@@@ release?
stack "$(dirname "$0")/release.hs" --no-test-haddocks upload
