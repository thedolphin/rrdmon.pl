#!/usr/bin/perl

use RRDs;

$imgbase='./graphs';

RRDs::graph 
    "--daemon",
    "unix:/var/run/rrdcached.sock",
    "$imgbase/net-bytes-eth0.png",
    "-s -1h",
    "-t traffic on eth0",
    "-h", "200", "-w", "580",
    "-l 0",
    "-a", "PNG",
    "-v bytes/sec",
    "DEF:in=/var/lib/rrdcached/db/all.rrd:net-bytes-in-eth0:AVERAGE",
    "DEF:out=/var/lib/rrdcached/db/all.rrd:net-bytes-out-eth0:AVERAGE",
    "CDEF:out_neg=out,-1,*",
    "AREA:in#32CD32:Incoming",
    "LINE1:in#336600",
    "GPRINT:in:MAX:  Max\\: %5.1lf %s",
    "GPRINT:in:AVERAGE: Avg\\: %5.1lf %S",
    "GPRINT:in:LAST: Current\\: %5.1lf %Sbytes/sec\\n",
    "AREA:out_neg#4169E1:Outgoing",
    "LINE1:out_neg#0033CC",
    "GPRINT:out:MAX:  Max\\: %5.1lf %S",
    "GPRINT:out:AVERAGE: Avg\\: %5.1lf %S",
    "GPRINT:out:LAST: Current\\: %5.1lf %Sbytes/sec\\n";

if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] $_[1] traffic graph: $ERROR\n"; }

