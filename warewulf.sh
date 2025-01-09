##  can not run automatically but should be able to cut/paste most
##  search for MANUALLY to see actions needed

################################################################################

##  warewulf - install

##  install services required for warewulf
dnf -y --setopt=install_weak_deps=False --nodocs install dhcp-server tftp-server nfs-utils golang unzip

##########

# clone warewulf from github
mkdir /opt/warewulf
git clone https://github.com/warewulf/warewulf.git /opt/warewulf/src
git checkout v4.5.8 -C /opt/warewulf/src
git apply ./configs/ww-picluster.patch -C /opt/warewulf/src

cd /opt/warewulf/src
make clean defaults PREFIX=/opt/warewulf
make all
make install

echo "export PATH=$PATH:/opt/warewulf/bin" > /etc/profile.d/warewulf.sh


## new warewulf wants to use grub but not us
##  see https://github.com/warewulf/warewulf/releases   for the new grub vs ipxe stuff
##  need to install the ipxe stuff....
##  in the install dir  edit cause we changed warewulf location install

# Will throw errors due to trying to build other architectures:
TARGETS=bin-arm64-efi/snponly.efi ./scripts/build-ipxe.sh


##  MANUALLY  MANUALLY  MANUALLY  MANUALLY  MANUALLY  MANUALLY
##  looks like a bug with the name of efi file referenced in dhcp and one installed for ipex
# cp -i /usr/local/warewulf/share/ipxe/bin-x86_64-efi-snponly.efi /var/lib/tftpboot/warewulf/ipxe-snponly-x86_64.efi

cd -