#!/usr/bin/env perl

use strict;
use warnings;

use Git::Hooks;

COMMIT_MSG {
    my ($git, $commit_msg_file) = @_;
    print "Ready to fail\n";
    return 0;
};


run_hook($0, @ARGV);
