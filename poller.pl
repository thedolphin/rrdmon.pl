package poller;

use RRDs;
use Data::Dumper;

use strict;

sub new {
    my $class = shift;
    my $self = {};

    $self->{'db'} = shift;
    $self->{'delay'} = shift || 30;

    bless($self,$class);
    return $self;
}

sub add {
    my $self = shift;
    my $item = shift;
    push(@{$self->{'items'}}, $item);
}


sub prepare {
    my $self = shift;
    my @params = ($self->{'db'}, "-s", $self->{'delay'});

    my $hartbeat = $self->{'delay'} * 2;

    foreach my $item (sort @{$self->{'items'}}) {
        my $res = $item->get();
        foreach my $atom (sort keys %{$res}) {
            push @params, 'DS:' . $atom .':'. $res->{$atom}->{'type'} .':'. $hartbeat .':U:U';
        }
    }

    push @params, "RRA:AVERAGE:0:1:" . 3600 / $self->{'delay'},         # store every value for one hour
                  "RRA:AVERAGE:0:" . 600 / $self->{'delay'} .':'. 72,   # store 10min average for 1 day
                  "RRA:AVERAGE:0:" . 3600 / $self->{'delay'} .':'. 72,  # store 1h average for 3 days
                  "RRA:AVERAGE:0:" . 43200 / $self->{'delay'} .':'. 30; # store 1day average for a month

    RRDs::create(@params);

    if (my $ERROR = RRDs::error) { 
        print Dumper(\@params);
        die "unable to create database: $ERROR\n";
    }
}

sub run {
    my $self = shift;
    my @template = ();
    my @values = ('N');
#    my @params = ($self->{'db'}, '--template');
    my @params = ($self->{'db'}, '--daemon', 'unix:/var/run/rrdcached.sock');

    foreach my $item (sort @{$self->{'items'}}) {
        my $res = $item->get();
        foreach my $atom (sort keys %{$res}) {
#            push @template, $atom;
            push @values, $res->{$atom}->{'value'};
        }
    }

#    push @params, join(':', @template), join(':', @values);
    push @params, join(':', @values);

    RRDs::update(@params);

    if (my $ERROR = RRDs::error) { 
        print Dumper(\@params);
        die "unable to update database: $ERROR\n";
    }
}

sub daemon {
    my $self = shift;
    while (1) {
        $self->run();
        sleep($self->{'delay'});
    }
}

1;
