#!/usr/bin/env perl

use strict;
use warnings;

use Git::Hooks;
use Term::ANSIColor;

use File::Slurp::Tiny qw(read_file write_file);
use Net::GitHub;
use Git::More;

use v5.14;

#Retrieve configuration
my $git = Git::More->repository();
my $api_key = $git->get_config( 'github','apikey' );
say $api_key;

my $gh = Net::GitHub->new(
    version => 3,
    access_token => $api_key
);

COMMIT_MSG {
    my ($git, $commit_msg_file) = @_;
    
    my $commit_msg = read_file( $commit_msg_file );
    say $commit_msg_file;
    
    return 1;

};


run_hook($0, @ARGV);