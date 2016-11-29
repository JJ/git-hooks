# `git` hooks with Perl

A few Git hooks for the Perl Advent article and for giving talks on same. 

Please remember that these hooks are not run in your shell, and they
will use system-wide installed Perl. So you will need to install the
corresponding modules, specially `File::Slurp::Tiny` if you want to
run them from your git repos.

The `cpanfile` is provided for your convenience, so you can install everything that's needed on the fly. 
