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
print Dumper(\%mount_s3fs_result);

sub mount_s3fs  {

	my $bucket_name=$config->{'s3'}->{'bucket_name'};
    my $ssh_command="ssh -o StrictHostKeyChecking=no";
	my $hosts_file = $config->{'aws'}->{'host_file'};
	my $scp_command="scp -o StrictHostKeyChecking=no";

	open(FH,"<$hosts_file") or die "cannot read host file\n";
	
	while(my $host = <FH>) {
		chomp($host);
		system("$scp_command .passwd-s3fs ubuntu\@$host:");
		my $flag = system ("$ssh_command ubuntu\@$host \"sudo mkdir -p /mnt/$bucket_name && sudo s3fs $bucket_name /mnt/$bucket_name && mount | grep s3fs\"");
		$mount_s3fs_result{$host} = $flag;
	}
}