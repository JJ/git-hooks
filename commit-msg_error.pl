#!/usr/bin/env perl

use strict;
use warnings;
use Git::Hooks;

COMMIT_MSG {
    print "This should fail\n";
    return 0;
};

run_hook($0, @ARGV);
