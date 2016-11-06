#!/usr/bin/env perl

use strict;
use warnings;

use Git::Hooks;
use Term::ANSIColor;

use File::Slurp::Tiny qw(read_file write_file);
use Net::GitHub;
use Git::More;
use Data::Dumper;

use v5.14;

#Retrieve configuration
my $git = Git::More->repository();
my $api_key = $git->get_config( 'github','apikey' );

my $gh = Net::GitHub->new(
    version => 3,
    access_token => $api_key
);
my $repos = $gh->repos;
my $origin = $git->get_config( 'remote.origin','url' );
my ( $user, $repo ) = ($origin =~ m{:(.+?)/(.+)\.git});
my $issue = $gh->issue();
my @these_issues = $issue->repos_issues( $user, $repo, { state => 'open'} );

my %issues_map;
for my $i ( @these_issues ) {
  $issues_map{$i->{'number'}} = $i->{'title'};
}

COMMIT_MSG {
    my ($git, $commit_msg_file) = @_;
    
    my $commit_msg = read_file( $commit_msg_file );
    
    my @issues = ($commit_msg =~ /\#(\d+)/g);
    my $addresses_issue = 0;

    if ( !@issues ) {
      say "This commit should address at least one issue";
      return 1;
    } else {
      for my $i ( @issues ) {
	if ( $issues_map{$i} ) {
	  say "Addresses issue $i: $issues_map{$i}";
	} else {
	  say "There is no issue $i";
	  $addresses_issue ||= 1;
	}
	say "Correct $addresses_issue";
      }
    }

    return $addresses_issue;
};


run_hook($0, @ARGV);
