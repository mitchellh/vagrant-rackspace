#!/bin/bash -e

if grep -q '!requiretty' "/etc/sudoers"; then
  echo 'requiretty workaround already applied'
else
  cp /etc/sudoers /etc/sudoers.tmp
  cp /etc/sudoers /etc/sudoers.orig
  echo 'Defaults !requiretty' >> /etc/sudoers.tmp
  visudo -c -s -f /etc/sudoers.tmp
  cp /etc/sudoers.tmp /etc/sudoers
  echo 'requiretty workaround applied'
fi
