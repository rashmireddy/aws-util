aws-util
========

perl interface to Amazon EC2 Environment

Requirements on Mac OSX
=======================
In order to run aws-util scripts, we need certain perl modules. Install cpanm to make installing other modules easier

```
# This will install cpanm
sudo cpan App::cpanminus
```

The following perl modules are required 

```
sudo cpanm VM::EC2
sudo cpanm Config::Tiny
sudo cpanm Amazon::S3
```

AWS config
===========

All scripts take aws.conf, which has aws access key, secret key, security group, ami image type etc

Example aws.conf

```
[aws]
access_key=<YOUR_ACCESS_KEY_HERE>
secret_key=<YOUR_SECRET_KEY_HERE>
endpoint=http://ec2.amazonaws.com
image=ami-8d756fe4
instance_type=t1.micro
security_group=<YOUR_SECURITY_GROUP_HERE>
key_name=<YOUR_KEY_PAIR_NAME_HERE>
# launch_instance.pl will write the new instance hostnames to this file.
host_file=hosts.txt
instance_count=2
region=us-west-1

[s3]
bucket_name=rashmireddy-awsutil-s3-01

[data]
files=data/4kb.txt,data/4kb.bin
ops=ops.pl
```


launch_instance.pl
===================
This script takes 1 param, a config file and creates a text file continaing a list of all the hostnames which are created successfully through EC2.

```
$ ./launch_instance.pl aws.conf
Creating 2 instances of RHEL-6.5_GA-x86_64-7-Hourly2 ...
i-4be56418: [running] ec2-54-227-32-176.compute-1.amazonaws.com
i-77e56424: [running] ec2-54-211-95-78.compute-1.amazonaws.com
$ 
```


install_s3fs.pl
================
This script takes 1 param, a aws.conf file which tells the name of the text file with list of hostnames on which s3fs should be installed. The script will scp install_s3fs.sh file to the remote host which does the installation.

```
$ ./install_s3fs.pl aws.conf

```

s3_bucket.pl
============
This script takes 1 param, a config file and creates a s3 bucket if it does not exists. If the s3 bucket exists then it clears the keys in the bucket.

```
$ ./s3_bucket.pl aws.conf
Adding bucket : AKIAIT3cvxcvx6UKYI6ZSZAMDQ-rashmireddy-awsutil-s3-01
$ ./s3_bucket.pl aws.conf
Keys cleared for bucket : AKIAIvkgvrtuI6ZSZAMDQ-rashmireddy-awsutil-s3-01
```


mount_s3fs.pl
=============
This script takes 1 param, a config file and mounts s3 bucket on the ec2 instances. If the dir is already mounted it just ignores.

```
$ ./mount_s3fs.pl aws.conf
....
....
SUCCESS : /mnt/rashmireddy-awsutil-s3-01 mounted on host : ec2-54-183-65-181.us-west-1.compute.amazonaws.com
SUCCESS : /mnt/rashmireddy-awsutil-s3-01 mounted on host : ec2-54-183-68-80.us-west-1.compute.amazonaws.com
SUCCESS : /mnt/rashmireddy-awsutil-s3-01 mounted on host : ec2-54-183-70-227.us-west-1.compute.amazonaws.com
SUCCESS : /mnt/rashmireddy-awsutil-s3-01 mounted on host : ec2-54-183-65-195.us-west-1.compute.amazonaws.com
```

s3fs_ops.pl
===========
This script takes 1 param, a config file and generates report for io operations

```
$ ./s3fs_ops.pl aws.conf
Rashmi:aws-util rashmi$ ./s3fs_ops.pl config/aws.conf 
Generating report, please wait...
For host : ec2-54-183-65-181.us-west-1.compute.amazonaws.com
For host : ec2-54-183-65-195.us-west-1.compute.amazonaws.com
For host : ec2-54-183-68-80.us-west-1.compute.amazonaws.com
For host : ec2-54-183-70-227.us-west-1.compute.amazonaws.com
```

Note : The IO operations data will be in the present working dir in hostname.log file


Issues encountered
==================

After running mount_s3fs.pl , the bucket is successfully mounted but we are not able to cd OR ls on that mount point.
e.g: 

```
Rashmi:aws-util rashmi$ ssh ubuntu@ec2-54-183-68-80.us-west-1.compute.amazonaws.com
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-24-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

  System information as of Tue May 27 20:39:29 UTC 2014

  System load:  0.0               Processes:           65
  Usage of /:   14.6% of 7.75GB   Users logged in:     0
  Memory usage: 14%               IP address for eth0: 172.31.9.55
  Swap usage:   0%

  Graph this data and manage this system at:
    https://landscape.canonical.com/

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud


Last login: Tue May 27 20:39:29 2014 from c-98-207-178-94.hsd1.ca.comcast.net
ubuntu@ip-172-31-9-55:~$ sudo s3fs -o url=http://s3.amazonaws.com rashmireddy-awsutil-s3-01 /mnt/rashmireddy-awsutil-s3-01
ubuntu@ip-172-31-9-55:~$ cd /m
media/ mnt/   
ubuntu@ip-172-31-9-55:~$ cd /m
media/ mnt/   
ubuntu@ip-172-31-9-55:~$ cd /mnt/
ubuntu@ip-172-31-9-55:/mnt$ ls
ls: cannot access rashmireddy-awsutil-s3-01: Permission denied
rashmireddy-awsutil-s3-01
ubuntu@ip-172-31-9-55:/mnt$ chmod 755 rashmireddy-awsutil-s3-01 
chmod: cannot access ‘rashmireddy-awsutil-s3-01’: Permission denied
ubuntu@ip-172-31-9-55:/mnt$ sudo chmod 755 rashmireddy-awsutil-s3-01 
chmod: cannot access ‘rashmireddy-awsutil-s3-01’: Transport endpoint is not connected
ubuntu@ip-172-31-9-55:/mnt$ 
```