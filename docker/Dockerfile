# syntax=docker/dockerfile:1
FROM ghcr.io/warewulf/warewulf-rockylinux:9
COPY yum.repos.d/* /etc/yum.repos.d/
RUN dnf update -y
RUN dnf install -y "https://github.com/warewulf/warewulf/releases/download/v4.5.8/warewulf-dracut-4.5.8-1.el9.noarch.rpm"
RUN dracut --verbose --force --no-hostonly --add wwinit --regenerate-all
RUN dnf install -y --downloadonly --downloaddir=/apps/pkgs/chrony chrony; echo
RUN dnf install -y --downloadonly --downloaddir=/apps/pkgs/slurm-compute slurm-slurmd munge; echo
RUN dnf install -y --downloadonly --downloaddir=/apps/pkgs/ipa-client ipa-client; echo
RUN dnf install -y --downloadonly --downloaddir=/apps/pkgs/glusterfs-client glusterfs-fuse; echo