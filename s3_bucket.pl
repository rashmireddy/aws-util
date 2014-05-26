#!/usr/bin/perl
use warnings;
use strict;
use Amazon::S3;
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

my $s3 = Amazon::S3->new( {   
          aws_access_key_id     => $config->{'aws'}->{'access_key'},
          aws_secret_access_key => $config->{'aws'}->{'secret_key'}
      });

my $bucket_name = $config->{'aws'}->{'access_key'} . "-".$config->{'s3'}->{'bucket_name'};

my $response = $s3->buckets;
my @active_buckets = @{$response->{'buckets'}};

foreach my $bucket_info (@active_buckets) {
  if($bucket_info->{'bucket'} eq $bucket_name) {
   my @bucket_keys = $bucket_info->list_all();
   foreach my $bucket_key(@bucket_keys) {
      $bucket_info->delete_key($bucket_key);
   }
   print "Keys cleared for bucket : $bucket_name\n";
   exit(0);
  }
}
print "Adding new bucket :  $bucket_name\n";
my $bucket = $s3->add_bucket( { bucket => $bucket_name } ) or die $s3->err . ": " . $s3->errstr;
