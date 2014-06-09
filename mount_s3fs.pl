#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Config::Tiny;

my $config_file = $ARGV[0];
my %mount_s3fs_result;
my $config = undef;

if(-e $config_file) {
    # Open the config
    $config = Config::Tiny->read($config_file);
} else {
  print STDERR "Config file not found\n";
}

mount_s3fs();
#print Dumper(\%mount_s3fs_result);

foreach my $key (keys %mount_s3fs_result) {
	if($mount_s3fs_result{$key} == 0) {
		print "SUCCESS : /mnt/" . $config->{'s3'}->{'bucket_name'} . " mounted on host : $key\n";
	}
	elsif($mount_s3fs_result{$key} == 9999){
		print "INFO : /mnt/" . $config->{'s3'}->{'bucket_name'} . " ALREADY mounted on host : $key\n";
	}
	else {
		print STDERR "ERROR : s3fs mount failed on host $key\n";
	}
}


sub mount_s3fs  {

	my $bucket_name=$config->{'s3'}->{'bucket_name'};
    my $ssh_command="ssh -o StrictHostKeyChecking=no";
	my $hosts_file = $config->{'aws'}->{'host_file'};
	my $scp_command="scp -q -o StrictHostKeyChecking=no";

	open(FH,"<$hosts_file") or die "cannot read host file\n";
	
	while(my $host = <FH>) {
		chomp($host);
		#first check for s3fs mount before mounting s3fs
		my $check_mount = system("$ssh_command ubuntu\@$host \"mount | grep $bucket_name > /dev/null\"");
		if($check_mount == 0){
			$mount_s3fs_result{$host} = 9999;
			next;
		}
		
		system("$scp_command .passwd-s3fs ubuntu\@$host:");
		#s3fs mount issues, removing actual mount command
		my $flag = system ("$ssh_command ubuntu\@$host \"sudo mkdir -p /mnt/$bucket_name && \
								sudo chown ubuntu:ubuntu /mnt/$bucket_name && \
								mkdir -p ~/cache && \
								sudo chmod -R 777 /mnt/$bucket_name
								\"");
=comment
		my $flag = system ("$ssh_command ubuntu\@$host \"sudo mkdir -p /mnt/$bucket_name && \
								sudo chown ubuntu:ubuntu /mnt/$bucket_name && \
								mkdir -p ~/cache && \
								sudo chmod -R 777 /mnt/$bucket_name && \
								sudo s3fs -o uid=1000,gid=1000,use_cache=/home/ubuntu/cache $bucket_name /mnt/$bucket_name && \
								mount
								\"");
=cut
		$mount_s3fs_result{$host} = $flag;
	}
}