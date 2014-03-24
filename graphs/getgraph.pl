#!/usr/bin/perl

use RRDs;

$imgbase='./graphs';

RRDs::graph
    "--daemon",
    "unix:/var/run/rrdcached.sock",
    "$imgbase/la-1d.png",
    "-s -24h",
    "-t load average",
    "-h", "200", "-w", "580",
    "-l 0",
    "-X 0",
    "-a", "PNG",
    "DEF:in=/var/lib/rrdcached/db/all.rrd:loadavg-1min:AVERAGE",
    "AREA:in#32CD32:LA",
    "LINE1:in#336600",
    "GPRINT:in:MAX:  Max\\: %3.2lf",
    "GPRINT:in:AVERAGE: Avg\\: %3.2lf ",
    "GPRINT:in:LAST: Current\\: %3.2lf\\n";

if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] $_[1] traffic graph: $ERROR\n"; }
