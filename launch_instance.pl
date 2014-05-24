#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use VM::EC2;
use Config::Tiny;

my $num_clients = $ARGV[0];
my $config_file = $ARGV[1];

my $config = undef;

if(-e $config_file) {
    # Open the config
        $config = Config::Tiny->read($config_file);
}

my @instances = create_instance($num_clients);

# print out instance's current state and DNS name
for my $i (@instances) {
    my $status = $i->current_status;
    my $dns    = $i->dnsName;
    #system("ssh ec2-user\@$dns 'date'");
    print "$i: [$status] $dns\n";
}

 sub create_instance {
    my ($num_clients) = @_;
 
    my $ec2 = VM::EC2->new(-access_key => $config->{'aws'}->{'access_key'},
                            -secret_key => $config->{'aws'}->{'secret_key'},
                            -endpoint   => $config->{'aws'}->{'endpoint'});

    # fetch an image by its ID 
    # We will use RHEL 6.5 64 bit image - ami-8d756fe4
    my $image = $ec2->describe_images($config->{'aws'}->{'image'});


    print "Creating " . $num_clients . " instances of " . $image->name  . " ...\n";
    # run instances
    my @instances = $image->run_instances(-key_name       => $config->{'aws'}->{'key_name'},
                                          -security_group => $config->{'aws'}->{'security_group'},
                                          -min_count      => $num_clients,
                                          -instance_type  => $config->{'aws'}->{'instance_type'})
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
