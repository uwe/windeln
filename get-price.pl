#!/usr/bin/env perl

use Mojo::Base -strict;
use Mojo::UserAgent;

use DBI;


my $dbh = DBI->connect(
    'dbi:mysql:windeln',
    $ENV{UWE_DB_USER} || 'windeln',
    $ENV{UWE_DB_PASS} || 'windeln',
    {RaiseError => 1},
);


my $ua = Mojo::UserAgent->new(max_redirects => 5);


my $site = $dbh->selectall_hashref('SELECT * FROM seite', 'id');

foreach my $site_id (sort keys %$site) {
    next unless $site_id == 2;

    my $amazon_url = $site->{$site_id}->{base_url};

    my $sql = 'SELECT * FROM produkt WHERE aktiv=1 AND seite_id=? ORDER BY asin';
    foreach my $row (@{$dbh->selectall_arrayref($sql, {Slice => {}}, $site_id)}) {
        eval {
            my $tx = $ua->get($amazon_url . $row->{asin});

            my $price = $tx->res->dom->at('b.priceLarge')->text;
            $price =~ s/EUR //;
            $price =~ tr/$,.//d;

            $dbh->do(
                'INSERT INTO preis (produkt_id, datum, preis) VALUES (?, UTC_TIMESTAMP(), ?)',
                {},
                $row->{id},
                $price,
            );
        };
    }
}

