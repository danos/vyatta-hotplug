#! /usr/bin/perl
#
# Script to communicate hotplug information with dataplane

# Copyright (c) 2019, AT&T Intellectual Property.
# Copyright (c) 2014, Brocade Comunications Systems, Inc.
# All Rights Reserved.
# SPDX-License-Identifier: GPL-2.0-only

use strict;
use warnings;

use Getopt::Long;
use Config::Tiny;

use lib "/opt/vyatta/share/perl5/";
use Vyatta::Dataplane qw(vplane_exec_cmd);

sub usage {
    print "Usage: $0 [--act=add/remove] [--pcislot=0000:00:0x:x]\n";
    exit 1;
}

my $fabric;
my $pcislot;
my $act;

GetOptions( 'fabric=s'  => \$fabric, 
            'act=s'     => \$act, 
            'pcislot=s' => \$pcislot, 
) or usage();

my ( $dpids, $dpsocks, $localcontroller ) = Vyatta::Dataplane::setup_fabric_conns();
vplane_exec_cmd("hotplug $act $pcislot", $dpids, $dpsocks, 0);
Vyatta::Dataplane::close_fabric_conns($dpids, $dpsocks);
