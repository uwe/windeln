#!/usr/bin/env perl

use strict;
use warnings;

use SVG::Sparkline;


my $sp = SVG::Sparkline->new(
    Line => {
        values => [10, 10, 10, 8, 10, 9, 10, 10, 9, 9],
        color  => 'black',
        height => 12,
    },
);

print $sp->to_string;


