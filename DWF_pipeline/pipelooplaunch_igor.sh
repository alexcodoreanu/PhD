#! /bin/csh -f
source /projects/p025_swin/pipes/arest/photpipe/config/DECAM/DEFAULT/DEFAULT.sourceme
set ut=$1
set ccd=$2
pipeloop.pl -red $ut $ccd