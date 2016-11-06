#!/usr/bin/env perl

use strict;
use warnings;

use Git::Hooks;

use File::Slurp::Tiny qw(read_file write_file);

use v5.14;

PREPARE_COMMIT_MSG {

    my ($git, $commit_msg_fn) = @_;
    my $commit_msg = read_file( $commit_msg_fn );
    die if !$commit_msg;

    my $diff_output = $git->command(qw/diff-index --cached -p HEAD/);

    my @lines_changed = ($diff_output =~ /-\d+,(\d+) \+\d*,?(\d+)/gs);

    my ($lines_added, $lines_taken);

    while ( @lines_changed ) {
	$lines_taken += shift @lines_changed;
	$lines_added += shift @lines_changed;
    }

    my $message="\nYou have added $lines_added and taken $lines_taken lines";
    
    if ( $commit_msg !~ /$message/ ) {
	write_file( $commit_msg_fn, $commit_msg.$message );
    }
};

say join("\n",@ARGV);
run_hook($0, @ARGV);
