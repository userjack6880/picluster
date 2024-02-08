# format new partition
fdisk /dev/sda
mke2fs -t ext4 /dev/sda3

# mount new partition
mkdir /mnt/shared
blkid | grep /dev/sda3 | awk '{ print $5 "\t/mnt/shared\text4\tdefaults\t0\t2" }' >> /etc/fstab
mount -a

# fix permissions
chgrp users /mnt/shared
chmod g+w /mnt/shared
ln -s /mnt/shared /shared

# install nfs server package
dpkg -i /apps/pkgs/nfs-kernel-server*.deb

# configure exports
echo "/home 10.0.0.0/24(rw,async,no_root_squash)" >> /etc/exports
echo "/mnt/apps 10.0.0.0/24(rw,async,no_root_squash)" >> /etc/exports
echo "/mnt/shared 10.0.0.0/24(rw,async,no_root_squash)" >> /etc/exports

# start nfs and export
systemctl enable nfs-server
systemctl start nfs-server
exportfs -a
