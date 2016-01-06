sentry-plugins
==============

Munin and Nagios plugins for a three-phase Server Tech PDU.

# Munin

For Munin: RTFM
* http://munin-monitoring.org/wiki/munin-node-configure
* http://munin.readthedocs.org/en/latest/tutorial/snmp.html

Quick and Dirty:

Assuming the hostname of your Server Tech PDU is **my-pdu** and you've configured SNMP appropriately, you can perform the following commands on the munin node you have designated for SNMP.

For Sentry3: (firmware 7.x)

Note: my sentry3 code is designed for and tested on 3-phase.

```
git clone https://github.com/dannyman/sentry-plugins.git
sudo cp sentry-plugins/munin/snmp__sentry3.pl /usr/share/munin/plugins/snmp__sentry3
sudo munin-node-configure --shell --snmp my-pdu
```

For Sentry4: (firmware 8.x)

Note: my sentry4 code is designed for and tested on single phase, 2 branches.

```
git clone https://github.com/dannyman/sentry-plugins.git
sudo cp sentry-plugins/munin/snmp__sentry4.pl /usr/share/munin/plugins/snmp__sentry4
sudo munin-node-configure --shell --snmp my-pdu
```

That should print out, for example:

```
ln -s /usr/share/munin/plugins/snmp__sentry3 /etc/munin/plugins/snmp_my-pdu_sentry3
```

So, you can:

```
sudo munin-node-configure --shell --snmp my-pdu | sudo sh
sudo service munin-node restart
```

You could then test things out with a sample run:
```
$ sudo munin-run snmp_my-pdu_sentry3
multigraph power_amps_drawn
Master_Y.value 3.76
Master_X.value 5.82
Master_Z.value 7.46
multigraph power_power_factor
Master_Y.value 0.91
Master_X.value 0.89
Master_Z.value 0.91
multigraph power_crest_factor
Master_Y.value 1.7
Master_X.value 1.8
Master_Z.value 1.7
```

Or:

```
$ sudo munin-run snmp_my-other-pdu_sentry4
multigraph power_amps_drawn
AA:BR1.value 1.89
AA:BR2.value 2.25
```

On your Munin Master node, add the node to your **/etc/munin/munin.conf** file.  This is explained at http://munin-monitoring.org/wiki/Using_SNMP_plugins.

You can build an aggregate graph across your PDUs like so:
```
[pdu-mtv.example.com;Aggregate]
    update no
    power_watts_total.graph_category power
    power_watts_total.graph_args --lower-limit 0
    power_watts_total.graph_vlabel kW
    power_watts_total.graph_scale no
    power_watts_total.graph_title Power Draw in Kilowatts
    power_watts_total.aggregate.label Power Draw in Kilowatts
    power_watts_total.aggregate.min 0
    power_watts_total.aggregate.colour dd0000
    power_watts_total.aggregate.sum \
      pdu-01.mtv.examples.com:power_amps_drawn.Master_X \
      pdu-01.mtv.examples.com:power_amps_drawn.Master_Y \
      pdu-01.mtv.examples.com:power_amps_drawn.Master_Z \
      pdu-02.mtv.examples.com:power_amps_drawn.Master_X \
      pdu-02.mtv.examples.com:power_amps_drawn.Master_Y \
      pdu-02.mtv.examples.com:power_amps_drawn.Master_Z \
      pdu-03.mtv.examples.com:power_amps_drawn.AA_BR1 \
      pdu-03.mtv.examples.com:power_amps_drawn.AA_BR2
	power_watts_total.aggregate.cdef aggregate,208,*,1000,/
```

The above assumes pdu-01 and pdu-02 are three-phase PDUs running on the
sentry3 plugin, and pdu-03 is a single-phase, two branch PDU running on
the sentry4 plugin.  The last line renders the graphs in Kilowatts by
multiplying Amps * 208V * 1000.  Your Voltage might be different.


# Nagios

Stay Tuned.
