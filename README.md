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
```

launch_instances.pl
===================
This script takes 2 params, num of instances to launch and a config file with aws access key, secret key, security group, ami image type etc

```
$ ./launch_instance.pl 2 aws.conf
Creating 2 instances of RHEL-6.5_GA-x86_64-7-Hourly2 ...
i-4be56418: [running] ec2-54-227-32-176.compute-1.amazonaws.com
i-77e56424: [running] ec2-54-211-95-78.compute-1.amazonaws.com
$ 
```

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
```


