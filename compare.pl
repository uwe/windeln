#!/usr/bin/env perl

use Mojo::Base -strict;

# Template::Plugin::Fix2
use lib 'lib';

use DBI;
use Template;


my $dbh = DBI->connect(
    'dbi:mysql:windeln',
    $ENV{UWE_DB_USER} || 'windeln',
    $ENV{UWE_DB_PASS} || 'windeln',
    {RaiseError => 1},
);

my $tt2 = Template->new({INCLUDE_PATH => '.'});


my $SITE = $dbh->selectall_hashref('SELECT * FROM seite',   'id');
my $SIZE = $dbh->selectall_hashref('SELECT * FROM groesse', 'id');
my $TYPE = $dbh->selectall_hashref('SELECT * FROM typ',     'id');

foreach my $site_id (sort keys %$SITE) {
    next unless $site_id == 2;

    my $data = {};
    my $site = $SITE->{$site_id};

    my $sql = 'SELECT * FROM produkt WHERE aktiv=1 AND seite_id=?';
    foreach my $row (@{$dbh->selectall_arrayref($sql, {Slice => {}}, $site_id)}) {
        my ($price) = $dbh->selectrow_array(
            'SELECT preis FROM preis WHERE produkt_id=? ORDER BY datum DESC', {},
            $row->{id},
        );
        next unless $price;

        $data->{$row->{typ_id}}{$row->{groesse_id}}{$row->{anzahl}} = {
            price => $price,
            cent  => sprintf('%.2f', $price / $row->{anzahl}),
            url   => sprintf($site->{affiliate_url}, $row->{asin}, $row->{asin}),
        };
    }

    my %var = (
        site => $site,
        DATA => $data,
        SIZE => $SIZE,
        TYPE => $TYPE,
    );
    $tt2->process('template.html', \%var, 'public/' . $site->{output}) or die $tt2->error;
}

