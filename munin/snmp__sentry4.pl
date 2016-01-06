#!/usr/bin/perl -w

=head1 NAME

Munin plugin snmp__sentry4 is written to monitor the Sentry line of Power Distribution Units (PDU) offered by Server Technology.

This plugin is written for and tested against a single-phase, two branch PDU.

This plugin supports Server Technology Sentry Switched CDU Version 8.x.

=head1 AUTHOR

Danny Howard <dannyman@toldme.com>

This plugin was created on the behalf of Quantifind, Inc.  http://www.quantifind.com

=head1 LICENSE

BSD

=head1 MAGIC MARKERS

  #%# family=snmpauto
  #%# capabilities=snmpconf

=head1 EXAMPLE MIB

$ wget ftp://ftp.servertech.com/Pub/SNMP/Sentry4/Sentry4.mib
$ snmpwalk -c public -v 2c -M +. -m +Sentry3-MIB 192.168.whatevs .1.3.6.1.4.1.1718.4.1.7
Sentry4-MIB::st4BranchCurrentHysteresis.0 = INTEGER: 10 tenth Amps
Sentry4-MIB::st4BranchID.1.1.1 = STRING: AA1
Sentry4-MIB::st4BranchID.1.1.2 = STRING: AA2
Sentry4-MIB::st4BranchLabel.1.1.1 = STRING: AA:BR1
Sentry4-MIB::st4BranchLabel.1.1.2 = STRING: AA:BR2
Sentry4-MIB::st4BranchCurrentCapacity.1.1.1 = INTEGER: 20 Amps
Sentry4-MIB::st4BranchCurrentCapacity.1.1.2 = INTEGER: 20 Amps
Sentry4-MIB::st4BranchPhaseID.1.1.1 = STRING: AA1
Sentry4-MIB::st4BranchPhaseID.1.1.2 = STRING: AA1
Sentry4-MIB::st4BranchOcpID.1.1.1 = STRING: AA1
Sentry4-MIB::st4BranchOcpID.1.1.2 = STRING: AA2
Sentry4-MIB::st4BranchOutletCount.1.1.1 = INTEGER: 15
Sentry4-MIB::st4BranchOutletCount.1.1.2 = INTEGER: 15
Sentry4-MIB::st4BranchState.1.1.1 = INTEGER: on(1)
Sentry4-MIB::st4BranchState.1.1.2 = INTEGER: on(1)
Sentry4-MIB::st4BranchStatus.1.1.1 = INTEGER: normal(0)
Sentry4-MIB::st4BranchStatus.1.1.2 = INTEGER: normal(0)
Sentry4-MIB::st4BranchCurrent.1.1.1 = INTEGER: 405 hundredth Amps
Sentry4-MIB::st4BranchCurrent.1.1.2 = INTEGER: 448 hundredth Amps
Sentry4-MIB::st4BranchCurrentStatus.1.1.1 = INTEGER: normal(0)
Sentry4-MIB::st4BranchCurrentStatus.1.1.2 = INTEGER: normal(0)
Sentry4-MIB::st4BranchCurrentUtilized.1.1.1 = INTEGER: 202 tenth percent
Sentry4-MIB::st4BranchCurrentUtilized.1.1.2 = INTEGER: 224 tenth percent
Sentry4-MIB::st4BranchNotifications.1.1.1 = BITS: C0 snmpTrap(0) email(1) 
Sentry4-MIB::st4BranchNotifications.1.1.2 = BITS: C0 snmpTrap(0) email(1) 
Sentry4-MIB::st4BranchCurrentLowAlarm.1.1.1 = INTEGER: 0 tenth Amps
Sentry4-MIB::st4BranchCurrentLowAlarm.1.1.2 = INTEGER: 0 tenth Amps
Sentry4-MIB::st4BranchCurrentLowWarning.1.1.1 = INTEGER: 0 tenth Amps
Sentry4-MIB::st4BranchCurrentLowWarning.1.1.2 = INTEGER: 0 tenth Amps
Sentry4-MIB::st4BranchCurrentHighWarning.1.1.1 = INTEGER: 140 tenth Amps
Sentry4-MIB::st4BranchCurrentHighWarning.1.1.2 = INTEGER: 140 tenth Amps
Sentry4-MIB::st4BranchCurrentHighAlarm.1.1.1 = INTEGER: 160 tenth Amps
Sentry4-MIB::st4BranchCurrentHighAlarm.1.1.2 = INTEGER: 160 tenth Amps


=cut

use strict;
use Munin::Plugin::SNMP;

if (defined $ARGV[0] and $ARGV[0] eq "snmpconf") {
        print "require 1.3.6.1.4.1.1718.4.1.7\n";
        exit 0;
}

my $session = Munin::Plugin::SNMP->session(-translate =>
                                           [ -timeticks => 0x0 ]);

my $sentry_h_2 = $session->get_hash (
	-baseoid	=> ".1.3.6.1.4.1.1718.4.1.7.2.1",
	-cols		=> {
		4 =>  'st4BranchLabel',
		6 =>  'st4BranchCurrentCapacity',
	}
);

my $sentry_h_3 = $session->get_hash (
	-baseoid	=> ".1.3.6.1.4.1.1718.4.1.7.3.1",
	-cols		=> {
		5 =>  'st4BranchCurrentUtilized',
	}
);

if (!defined $sentry_h_2 || !defined $sentry_h_3) {
	printf "ERROR: %s\n", $session->error();
	$session->close();
	my $host;
	my $port;
	my $version;
	my $tail;
	($host, $port, $version, $tail) = Munin::Plugin::SNMP->config_session();
	print "host: $host\nport: $port\nversion: $version\ntail: $tail\n";
	exit 1;
}

if (defined $ARGV[0] and $ARGV[0] eq "config") {
    my ($host) = Munin::Plugin::SNMP->config_session();
	print "host_name $host\n" unless $host eq 'localhost';
	print "
multigraph power_amps_drawn
graph_title Power Draw in Amps
graph_args --lower-limit 0
graph_vlabel Amps
graph_category power
graph_scale no
graph_info This shows the amperage drawn on your PDU. Per NEC, a PDU should not sustain 80% of its maximum circuit capacity for more than three hours.

";

    foreach my $k ( keys %{$sentry_h_2} ) {
    	my $infeedName = $sentry_h_2->{$k}->{'st4BranchLabel'};
    	my $critical   = ($sentry_h_2->{$k}->{'st4BranchCurrentCapacity'})*.9;	# 90% of capacity
    	my $warning	   = ($sentry_h_2->{$k}->{'st4BranchCurrentCapacity'})*.8;	# 80% of capacity
    	
    	print "$infeedName.critical $critical\n";
    	print "$infeedName.draw LINE1\n";
    	print "$infeedName.label $infeedName\n";
    	print "$infeedName.min 0\n";
    	print "$infeedName.type GAUGE\n";
    	print "$infeedName.warning $warning\n";
    }

    exit 0;
}

print "multigraph power_amps_drawn\n";
foreach my $k ( keys %{$sentry_h_2} ) {
    my $infeedName = $sentry_h_2->{$k}->{'st4BranchLabel'};
	my $amps = $sentry_h_3->{$k}->{'st4BranchCurrentUtilized'};
	if ( $amps ) {
		$amps = $amps * .01;
	} else {
		$amps = 'U';
	}
	print "$infeedName.value $amps\n";
}
