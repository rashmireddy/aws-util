# following http://zentraal.com/docs/installing-s3fs-on-ubuntu

# problem encountered in fuse-utils on ubuntu, while it worked on RHEL.
# refer http://askubuntu.com/questions/370398/how-to-get-a-drive-formatted-with-exfat-working

sudo  apt-add-repository ppa:relan/exfat
sudo apt-get update

sudo apt-get -y install build-essential  libfuse-dev exfat-utils  libcurl4-openssl-dev libxml2-dev mime-support

sudo apt-get -y install gcc exfat-utils exfat-fuse fuse libxml2-dev libcurl4-openssl-dev build-essential libcurl4-openssl-dev libxml2-dev libfuse-dev comerr-dev libfuse2 libidn11-dev libkrb5-dev libldap2-dev libselinux1-dev libsepol1-dev pkg-config fuse-utils sshfs curl

rm -rf ~/downloads
mkdir ~/downloads

cd ~/downloads
wget http://sourceforge.net/projects/fuse/files/fuse-2.X/2.8.6/fuse-2.8.6.tar.gz/download
mv download fuse-2.8.6.tar.gz
tar -xvzf fuse-2.8.6.tar.gz 
cd fuse-2.8.6
./configure --prefix=/usr
make
sudo make install

cd ~/downloads
wget http://s3fs.googlecode.com/files/s3fs-1.74.tar.gz
tar -xvzf s3fs-1.74.tar.gz 
cd s3fs-1.74
./configure --prefix=/usr
make
sudo make install
