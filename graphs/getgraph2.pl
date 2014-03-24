#!/usr/bin/perl

use RRDs;

$imgbase='./graphs';

RRDs::graph 
    "--daemon",
    "unix:/var/run/rrdcached.sock",
    "$imgbase/mem.png",
    "-s -1h",
    "-t memory usage",
    "-h", "200", "-w", "580",
    "-l 0",
    "-a", "PNG",
    "-v bytes",
    "DEF:free=/var/lib/rrdcached/db/all.rrd:memory-free:AVERAGE",
    "DEF:buffers=/var/lib/rrdcached/db/all.rrd:memory-buffers:AVERAGE",
    "DEF:caches=/var/lib/rrdcached/db/all.rrd:memory-cached:AVERAGE",
    "DEF:used=/var/lib/rrdcached/db/all.rrd:memory-used:AVERAGE",
    "CDEF:free_k=free,1024,*",
    "CDEF:buffers_k=buffers,1024,*",
    "CDEF:caches_k=caches,1024,*",
    "CDEF:used_k=used,1024,*",
    "AREA:used_k#FF0000:Used",
    "STACK:caches_k#0000FF:Caches",
    "STACK:buffers_k#FF00FF:Buffers",
    "STACK:free_k#00FF00:Free",
    "GPRINT:free_k:MAX:  Max\\: %5.1lf %s",
    "GPRINT:free_k:AVERAGE: Avg\\: %5.1lf %S",
    "GPRINT:free_k:LAST: Current\\: %5.1lf %Sbytes\\n",
    "GPRINT:caches_k:MAX:  Max\\: %5.1lf %s",
    "GPRINT:caches_k:AVERAGE: Avg\\: %5.1lf %S",
    "GPRINT:caches_k:LAST: Current\\: %5.1lf %Sbytes\\n",
    "GPRINT:buffers_k:MAX:  Max\\: %5.1lf %S",
    "GPRINT:buffers_k:AVERAGE: Avg\\: %5.1lf %S",
    "GPRINT:buffers_k:LAST: Current\\: %5.1lf %Sbytes\\n",
    "GPRINT:used_k:MAX:  Max\\: %5.1lf %S",
    "GPRINT:used_k:AVERAGE: Avg\\: %5.1lf %S",
    "GPRINT:used_k:LAST: Current\\: %5.1lf %Sbytes\\n";

if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] $_[1] traffic graph: $ERROR\n"; }

