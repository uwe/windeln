#!/usr/bin/env perl

use strict;
use warnings;

use GD::Sparkline;


my $sp = GD::Sparkline->new(
    {
        s => q[10, 10, 10, 8, 10, 9, 10, 10, 9, 9],
    },
);

print $sp->draw;


