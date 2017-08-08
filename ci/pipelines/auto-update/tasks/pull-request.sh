#!/usr/bin/env bash

set -e
set -x

export GITHUB_TOKEN=${bosh_openstack_cpi_release_github_token}
export SSH_KEY="ssh.key"
echo "${bosh_openstack_cpi_release_github_key}" > ${SSH_KEY}
eval $(ssh-agent)
chmod go-r ${SSH_KEY}
ssh-add ${SSH_KEY}

cd bosh-cpi-src-out
echo "Check if latest auto-update commit has already been merged to master"
git fetch origin master:refs/remotes/origin/master
new_commits_available=$(git branch master --contains $(git rev-parse origin/auto-update))
pull_request=$(hub issue | grep "Bump gems") || no_pull_request=$?
if [ -z ${new_commits_available} ]; then
  if [ -v no_pull_request ]; then
    echo "Creating pull-request"
    hub pull-request -b master -h auto-update -m "Bump gems"
  else
    echo "Open pull-request found: ${pull_request}"
  fi
else
  echo "No new commits available"
fi
