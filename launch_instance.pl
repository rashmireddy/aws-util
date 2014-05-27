#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use VM::EC2;
use Config::Tiny;


my $config_file = $ARGV[0];

my $config = undef;

if(-e $config_file) {
    # Open the config
        $config = Config::Tiny->read($config_file);
}

my $num_clients = $config->{'aws'}->{'no_instances'};

my @instances = create_instance($num_clients);

if(scalar(@instances) > 0 ) {
    open(FH,">" . $config->{'aws'}->{'host_file'}) or die "cannot create file";
}

# print out instance's current state and DNS name
# Also write the host names to a file
for my $i (@instances) {
    my $status = $i->current_status;
    my $dns    = $i->dnsName;
    #system("ssh ec2-user\@$dns 'date'");
    print "$i: [$status] $dns\n";
    print FH "$dns\n";
}

 sub create_instance {
    my ($num_clients) = @_;
 
    my $ec2 = VM::EC2->new(-access_key => $config->{'aws'}->{'access_key'},
                            -secret_key => $config->{'aws'}->{'secret_key'},
                            -endpoint   => $config->{'aws'}->{'endpoint'},
                            -raise_error => "true",
                            -print_error => "true",
                            -region => $config->{'aws'}->{'region'});
    print Dumper($ec2);
    # fetch an image by its ID 
    # We will use Ubuntu Server 14.04 LTS (PV) 64 bit image - ami-ee4f77ab
    my $image = $ec2->describe_images($config->{'aws'}->{'image'});

    #print Dumper($image);
    #print "Creating " . $num_clients . " instances of " . $image->name  . " ...\n";
    # run instances
    my @instances = $image->run_instances(
                                          -key_name       => $config->{'aws'}->{'key_name'},
                                          -security_group => $config->{'aws'}->{'security_group'},
                                          -min_count      => $num_clients,
                                          -instance_type  => $config->{'aws'}->{'instance_type'}
                                        )
            or die $ec2->error_str;

    # wait for instances to reach "running" or other terminal state
    $ec2->wait_for_instances(@instances);

    # tag instances with Role "server"
    foreach my $instance (@instances) {
        #print $instance->current_status."\n";
        $instance->add_tag(Role=>'server');
    }

    return(@instances);    
}

