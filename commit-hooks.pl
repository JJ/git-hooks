#!/usr/bin/env perl

use strict;
use warnings;

use Git::Hooks;

use File::Slurp::Tiny qw(read_file write_file);

use v5.14;

sub diff_output {
    my $git = shift;
    $git->command('diff-index', '--cached','-p','HEAD');
}

PRE_COMMIT {
    my ($git) = @_;

    my @files_changed = (diff_output( $git) =~ /\++\sb\/(\S+)/gs);
 
    my $syntax_ok = 0;
    foreach my $file ( @files_changed ) {
	next if ( $file !~ /\.p[ml]/ );
	print "Checking $file  ";
	my $output = `perl -cw $file 2>&1`;
	if ($output =~ /syntax error/ ) {
	    $syntax_ok = $syntax_ok || 1;
	    say color("red"), "✗", color("reset"), "\n\tThere's an error in $file:", color("red"),
	    join("",map( "\n\t$_", split("\n",$output))), color("reset");
	} else {
	    say color("green"),"✓", color("reset");
	}
    }
    return $syntax_ok;
};


PREPARE_COMMIT_MSG {

    my ($git, $commit_msg_fn) = @_;
    my $commit_msg = read_file( $commit_msg_fn );
    die if !$commit_msg;

    my @lines_changed = (diff_output( $git ) =~ /-\d+,(\d+) \+\d*,?(\d+)/gs);

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
