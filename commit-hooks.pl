#!/usr/bin/env perl

use strict;
use warnings;

use Git::Hooks;
use Term::ANSIColor;
use Net::GitHub;
use Git::More;

use File::Slurp::Tiny qw(read_file write_file);

use v5.14;

sub diff_output {
    my $git = shift;
    $git->command('diff-index', '--cached','-p','HEAD');
}

sub fail {
    my $message = shift;
    return color("red")."✗ ".color("reset").$message;
}

sub pass {
    my $message = shift;
    return color("green")."✓ ".color("white").$message.color("reset");
}

PRE_COMMIT {
    my ($git) = @_;

    my @files_changed = (diff_output( $git) =~ /\++\sb\/(\S+)/gs);
 
    my $syntax_ok = 0;
    foreach my $file ( @files_changed ) {
	next if ( $file !~ /\.p[ml]/ );
	say "Checking syntax";
	my $output = `perl -cw $file 2>&1`;
	if ($output =~ /syntax error/ ) {
	    $syntax_ok = $syntax_ok || 1;
	    say "\t",fail( $file), color("red"),
	    join("",map( "\n\t$_", split("\n",$output))), color("reset");
	} else {
	    say "\t",pass( $file );
	}
	say "∆∇";
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

COMMIT_MSG {
    my ($git, $commit_msg_file) = @_;

    my $git_repo = Git::More->repository();
    my $api_key = $git_repo->get_config( 'github','apikey' );
    
    my $gh = Net::GitHub->new(
	version => 3,
	access_token => $api_key
	);
    my $repos = $gh->repos;
    my $origin = $git_repo->get_config( 'remote.origin','url' );
    my ( $user, $repo ) = ($origin =~ m{:(.+?)/(.+)\.git});
    my $issue = $gh->issue();
    my @these_issues = $issue->repos_issues( $user, $repo, { state => 'open'} );
    
    my %issues_map;
    for my $i ( @these_issues ) {
	$issues_map{$i->{'number'}} = $i->{'title'};
    }
    
    my $commit_msg = read_file( $commit_msg_file );
    
    my @issues = ($commit_msg =~ /\#(\d+)/g);

    if ( !@issues ) {
      say "This commit should address at least one issue";
      return 0;
    } else {
      my $addresses_issue = 1;
      for my $i ( @issues ) {
    	if ( $issues_map{$i} ) {
    	  say pass("Addresses issue $i: $issues_map{$i}");
    	  $addresses_issue &&= 1;
    	} else {
    	  say fail("There is no issue $i");
    	  $addresses_issue &&= 0;
    	}
      }
      say "∆∇";
      return $addresses_issue;
    }
};



run_hook($0, @ARGV);
