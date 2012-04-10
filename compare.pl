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


my $data = {};
my $size = $dbh->selectall_hashref('SELECT * FROM groesse', 'id');
my $type = $dbh->selectall_hashref('SELECT * FROM typ',     'id');

my $sql = 'SELECT * FROM produkt';
foreach my $row (@{$dbh->selectall_arrayref($sql, {Slice => {}})}) {
    my ($price) = $dbh->selectrow_array(
        'SELECT preis FROM preis WHERE produkt_id=? ORDER BY datum DESC', {},
        $row->{id},
    );
    next unless $price;

    $data->{$row->{typ_id}}{$row->{groesse_id}}{$row->{anzahl}} = {
        price => $price,
        cent  => sprintf('%.2f', $price / $row->{anzahl}),
        url   => sprintf('http://www.amazon.de/gp/product/%s/ref=as_li_ss_tl?ie=UTF8&tag=windeln05-21&linkCode=as2&camp=1638&creative=19454&creativeASIN=%s', $row->{asin}, $row->{asin}),
    };
}

my %var = (
    DATA => $data,
    SIZE => $size,
    TYPE => $type,
);
$tt2->process('template.html', \%var, 'public/index.html') or die $tt2->error;

