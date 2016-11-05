#!/usr/bin/env perl

use strict;
use warnings;

use Git;

use File::Slurp::Tiny qw(read_file write_file);
use PPI;

use v5.14;

my $repo = Git->repository();

my $diff_output = $repo->command('diff-index', '--cached','-p','HEAD');

my @files_changed = ($diff_output =~ /\++\sb\/(\W+)/gs);
 
say @files_changed;

my $syntax_ok = 0;
foreach my $file ( @files_changed ) {
    my $file_content = read_file( $file );
    my $document = PPI::Document->new( $file_content );
    if ($document->errstr) {
	$syntax_ok = $syntax_ok || 1;
	say "There's an error in $file: \n\t", $document->errstr;
    }
}

say "Syntax is $syntax_ok";
exit $syntax_ok;
