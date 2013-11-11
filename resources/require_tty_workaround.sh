#!/bin/bash -e

sed -i'.bk' -e 's/^\(Defaults\s\+requiretty\)/# \1/' /etc/sudoers
