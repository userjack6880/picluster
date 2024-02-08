# prepare /home
rm -r /home/admin

# create mount points
mkdir /apps
mkdir /shared

# update fstab
echo "pi-hpc-head01:/home /home nfs4 defaults,user,exec 0 0" >> /etc/fstab
echo "pi-hpc-head01:/mnt/apps /apps nfs4 defaults,user,exec 0 0" >> /etc/fstab
echo "pi-hpc-head01:/mnt/shared /shared nfs4 defaults,user,exec 0 0" >> /etc/fstab

# mount nfs mounts
mount -a
