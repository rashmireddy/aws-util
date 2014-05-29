#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Config::Tiny;

my $config_file = $ARGV[0];
my $config = undef;

if(-e $config_file) {
    # Open the config
    $config = Config::Tiny->read($config_file);
} else {
  print STDERR "Config file not found\n";
}

scp_dataops();

sub scp_dataops {
	my $data_files=$config->{'data'}->{'files'};
	my $ops_file=$config->{'data'}->{'ops'};
	my $hosts_file = $config->{'aws'}->{'host_file'};

	my @datafiles = split(",",$data_files);

	open(FH,"<$hosts_file") or die "cannot read host file\n";
	
	print "Generating report, please wait...\n";

	while(my $host = <FH>) {
		chomp($host);
		print "For host : $host\n";
		foreach my $i (@datafiles) {
			system("scp -q -o StrictHostKeyChecking=no $i ubuntu\@$host:");
		}

		# scp IO operations script
		system("scp -q -o StrictHostKeyChecking=no $ops_file ubuntu\@$host:");
		# scp aws.conf
		system("scp -q -o StrictHostKeyChecking=no $config_file ubuntu\@$host:");

		# Run the IO operations perl script on the remote instance
		system("ssh -o StrictHostKeyChecking=no ubuntu\@$host \"rm -f io.log && ~/ops.pl >> ~/io.log\"");
		system("scp -q -o StrictHostKeyChecking=no ubuntu\@$host:~/io.log report/$host.log")
	}
}

