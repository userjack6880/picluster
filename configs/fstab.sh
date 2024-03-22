#! /bin/bash

blkid /dev/sda1 | awk '{ print "$5\t/data/brick1\txfs\tdefaults\t1\t2" }' | tee -a /etc/fstab