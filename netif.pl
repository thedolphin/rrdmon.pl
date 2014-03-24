#!/usr/bin/perl

package netif;

use strict;

sub new {
    my $class = shift;
    my $self = {};

    $self->{'filter'} = shift;

    bless($self,$class);
    return $self;
}

sub get {
    my $self = shift;
    my $ifstats;

    open(my $fh, "</proc/net/dev") || die $!;

    while(<$fh>) {
        next if !/:/;
        chomp;

        (my $ifname, my @line) = split;
        chop $ifname;

        next if $ifname !~ $self->{'filter'};

        $ifstats->{"net-bytes-in-$ifname"}    = {'value' => $line[0], 'type' => 'COUNTER'};
        $ifstats->{"net-pkt-in-$ifname"}  = {'value' => $line[1], 'type' => 'COUNTER'};
        $ifstats->{"net-bytes-out-$ifname"}   = {'value' => $line[8], 'type' => 'COUNTER'};
        $ifstats->{"net-pkt-out-$ifname"} = {'value' => $line[9], 'type' => 'COUNTER'};
        
    }

    close($fh);

    return $ifstats;
}

return 1;


# 0 - bytes in
# 1 - packets in
# 2 - errors in
# 3 - drop in
# 4 - fifo in
# 5 - frame in
# 6 - compressed in
# 7 - multicast in
# 8 - bytes out
# 9 - packets out
# 10 - errors out
# 11 - drop out
# 12 - fifo out
# 13 - frame out
# 14 - compressed out

