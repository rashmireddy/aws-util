#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Config::Tiny;

my $config_file = $ARGV[0];
my $file=undef;
my $config = undef;

my %hosts_scp_result;
my %hosts_install_s3fs_result;

if(-e $config_file) {
	# Open the config
    $config = Config::Tiny->read($config_file);
    $file = $config->{'aws'}->{'host_file'};

	if(-e $file) {
		scp_s3fs_install_file($file);
		ssh_s3fs_run_install();
	} else {
		print STDERR "host file not found";
	}
} else {
	print STDERR "Config file not found\n";
}

sub scp_s3fs_install_file {
	my ($host_file) = @_;

	open(FH,"< $host_file") or die("Could not open file.");

	my $scp_command="scp -q -o StrictHostKeyChecking=no";

	while(my $host = <FH>) {
		chomp $host;
		
		my $flag=system("$scp_command install_s3fs.sh ubuntu\@$host:");
		if($flag !=0) {
			print STDERR "ERROR : failed to scp install file to $host\n";
		}
		$hosts_scp_result{$host} = $flag;
	}	
}


sub ssh_s3fs_run_install {
	
	while ( my ($host, $value) = each(%hosts_scp_result) ) {
		if($value == 0){
			#print("ssh -o StrictHostKeyChecking=no ubuntu\@$host \"~/install_s3fs.sh\"");
			my $flag = system("ssh -o StrictHostKeyChecking=no ubuntu\@$host \"~/install_s3fs.sh\"");
			if($flag !=0) {
				print STDERR "ERROR : failed to install s3fs on $host\n";
			}
			$hosts_install_s3fs_result{$host} = $flag;
		}
	}
}
