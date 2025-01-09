##  can not run automatically but should be able to cut/paste most
##  search for MANUALLY to see actions needed

################################################################################

##  warewulf - install

##  install services required for warewulf
dnf -y --setopt=install_weak_deps=False --nodocs install dhcp-server tftp-server nfs-utils golang

##########

# clone warewulf from github
mkdir /opt/warewulf
git clone https://github.com/warewulf/warewulf.git /opt/warewulf/src
cd !$
git checkout v4.5.8

make clean defaults PREFIX=/opt/warewulf
make all
make install


## new warewulf wants to use grub but not us
##  see https://github.com/warewulf/warewulf/releases   for the new grub vs ipxe stuff
##  need to install the ipxe stuff....
##  in the install dir  edit cause we changed warewulf location install

./scripts/build-ipxe.sh


##  MANUALLY  MANUALLY  MANUALLY  MANUALLY  MANUALLY  MANUALLY
##  looks like a bug with the name of efi file referenced in dhcp and one installed for ipex
# cp -i /usr/local/warewulf/share/ipxe/bin-x86_64-efi-snponly.efi /var/lib/tftpboot/warewulf/ipxe-snponly-x86_64.efi

cd -