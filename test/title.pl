#!/usr/bin/env perl

use Mojo::Base -strict;
use Mojo::UserAgent;


my $domain = $ARGV[0] || 'de';


my $ua = Mojo::UserAgent->new(max_redirects => 5);

foreach my $asin (<STDIN>) {
    chomp $asin;
    my $tx = $ua->get('http://www.amazon.' . $domain . '/dp/' . $asin);
    say $asin;
    say $tx->res->dom->html->head->title->text;
}

