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

my $sql = 'SELECT * FROM produkt WHERE aktiv=1 ORDER BY asin';
foreach my $row (@{$dbh->selectall_arrayref($sql, {Slice => {}})}) {
    eval {
        my $tx = $ua->get('http://www.amazon.de/dp/' . $row->{asin});

        my $price = $tx->res->dom->at('b.priceLarge')->text;
        $price =~ s/EUR //;
        $price =~ s/,//;

        $dbh->do(
            'INSERT INTO preis (produkt_id, datum, preis) VALUES (?, UTC_TIMESTAMP(), ?)',
            {},
            $row->{id},
            $price,
        );
    };
}

