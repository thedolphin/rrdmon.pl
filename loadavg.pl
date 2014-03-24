#!/usr/bin/perl

package loadavg;

use strict;

sub new {
    my $class = shift;
    my $self = {};

    bless($self,$class);
    return $self;
}

sub get {
    my $self = shift;
    my $stats = {};

    open(my $fh, "</proc/loadavg") || die $!;

    $_ = <$fh>;

    (
        $stats->{'loadavg-1min'}->{'value'},
        $stats->{'loadavg-5min'}->{'value'},
        $stats->{'loadavg-10min'}->{'value'},
        my $proc
    )  = split;

    close($fh);

    (
        $stats->{'processes-active'}->{'value'},
        $stats->{'processes-total'}->{'value'}
    ) = split /\//, $proc;

    open(my $fh, "</proc/meminfo") || die $!;

    while(<$fh>) {
        (my $type, my $amount) = /^(.+?):\s+(\d+) kB$/;

        $stats->{'memory-total'}->{'value'}   = $amount if ($type eq 'MemTotal');
        $stats->{'memory-free'}->{'value'}    = $amount if ($type eq 'MemFree');
        $stats->{'memory-buffers'}->{'value'} = $amount if ($type eq 'Buffers');
        $stats->{'memory-cached'}->{'value'}   = $amount if ($type eq 'Cached');

    }

    close($fh);

    $stats->{'memory-used'}->{'value'} =
        $stats->{'memory-total'}->{'value'}
        - $stats->{'memory-free'}->{'value'}
        - $stats->{'memory-buffers'}->{'value'}
        - $stats->{'memory-cached'}->{'value'};

    foreach my $key (keys %{$stats}) {
        $stats->{$key}->{'type'} = 'GAUGE';
    }

    return $stats;
}

return 1;
