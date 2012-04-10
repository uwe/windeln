#!/usr/bin/env perl

use Mojo::Base -strict;
use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new(max_redirects => 5);

foreach my $asin (<STDIN>) {
    chomp $asin;
    my $tx = $ua->get('http://www.amazon.de/dp/' . $asin);
    say $asin;
    say $tx->res->dom->html->head->title->text;
}

