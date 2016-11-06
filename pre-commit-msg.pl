#!/usr/bin/env perl

use strict;
use warnings;

use Git;
use Term::ANSIColor;

use v5.14;

my $repo = Git->repository();

my $diff_output = $repo->command('diff-index', '--cached','-p','HEAD');

my @files_changed = ($diff_output =~ /\++\sb\/(\S+)/gs);
 
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

exit $syntax_ok;
