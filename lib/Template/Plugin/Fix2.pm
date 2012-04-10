package Template::Plugin::Fix2;
$VERSION = '0.01';

use strict;
use warnings;

use base 'Template::Plugin';


sub new {
    my ($self, $context) = @_;

    $context->define_filter('fix2', \&fix2, '');

    return $self;
}

sub fix2 {
    my $number = shift;

    return undef unless defined $number;
    return '' if $number eq '';

    # convert to number
    $number = int($number);

    my $minus = 0;
    $minus = 1 if $number =~ s/^-//;

    while (length $number <= 2) {
        $number = '0'.$number;
    }

    $number = '-'.$number if $minus;

    my $after = substr($number, -2, 2, '');

    return _komma(join('.', $number, $after));
}

sub _komma {
    my $number = shift;
    my @number = split(/\./, $number);
    my $ready  = '';

    while ($number[0] =~ /([+-]?\d+)(\d{3})$/) {
        $number[0] = $1;
        $ready     = '.'.$2.$ready;
    }
    $ready = $number[0].$ready;

    if ($number[1]) {
        $ready .= ",$number[1]";
    }

    return $ready;
}


1;
