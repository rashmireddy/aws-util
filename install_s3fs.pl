#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $file = $ARGV[0];

my %hosts_scp_result;
my %hosts_install_s3fs_result;

if(-e $file) {
	scp_s3fs_install_file($file);
	ssh_s3fs_run_install();
} else {
	print STDERR "Host file not found\n";
}



sub scp_s3fs_install_file {
	my ($host_file) = @_;

	open(FH,"<$host_file") or die("Could not open file.");

	my $scp_command="scp -o StrictHostKeyChecking=no";

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
	#print Dumper(\%hosts_scp_result);
	while ( my ($host, $value) = each(%hosts_scp_result) ) {
		if($value == 0){
			print("ssh -o StrictHostKeyChecking=no ubuntu\@$host \"~/install_s3fs.sh\"");
			my $flag = system("ssh -o StrictHostKeyChecking=no ubuntu\@$host \"~/install_s3fs.sh\"");
			if($flag !=0) {
				print STDERR "ERROR : failed to install s3fs on $host\n";
			}
			$hosts_install_s3fs_result{$host} = $flag;
		}
	}
}
