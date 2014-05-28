#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Time::HiRes qw(gettimeofday);

# hard coding 4kb.txt and 4kb.bin data files
my @datafiles=("4kb.txt","4kb.bin");


write_file();
read_file();
delete_file();

sub delete_file {
	foreach my $dfile (@datafiles) {
		for(my $i=0;$i<100;$i++) {
			my $one=gettimeofday();
			system("rm /mnt/rashmireddy-awsutil-s3-01/$dfile.$i");
			my $two=gettimeofday();
			my $timediff = ($two-$one) * 1000 ;
			print "DELETE\t$dfile.$i\t$timediff\n";
		}
	}
}

sub read_file {
	foreach my $dfile (@datafiles) {
		for(my $i=0;$i<100;$i++) {
			my $one=gettimeofday();
			system("cp /mnt/rashmireddy-awsutil-s3-01/$dfile.$i /tmp/$dfile");
			my $two=gettimeofday();
			my $timediff = ($two-$one) * 1000;
			print "READ\t$dfile.$i\t$timediff\n";
		}
	}
}

sub write_file {
	foreach my $dfile (@datafiles) {
		for(my $i=0;$i<100;$i++) {
			my $one=gettimeofday();
			system("cp ~/$dfile /mnt/rashmireddy-awsutil-s3-01/$dfile.$i");
			my $two=gettimeofday();
			my $timediff = ($two-$one) * 1000;
			print "WRITE\t$dfile.$i\t$timediff\n";
		}
	}
}