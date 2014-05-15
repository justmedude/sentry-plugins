sentry-plugins
==============

Munin and Nagios plugins for a three-phase Server Tech PDU.

# Munin

For Munin: RTFM
* http://munin-monitoring.org/wiki/munin-node-configure
* http://munin-monitoring.org/wiki/Using_SNMP_plugins

Quick and Dirty:

Assuming the hostname of your Server Tech PDU is **my-pdu** and you've configured SNMP appropriately, you can perform the following commands on the munin node you have designated for SNMP:

```
git clone https://github.com/dannyman/sentry-plugins.git
sudo cp sentry-plugins/munin/snmp__sentry.pl /usr/share/munin/plugins/snmp__sentry
sudo munin-node-configure --shell --snmp my-pdu
```

That should print out, for example:

```
ln -s /usr/share/munin/plugins/snmp__sentry /etc/munin/plugins/snmp_my-pdu_sentry
```

So, you can:

```
sudo munin-node-configure --shell --snmp my-pdu | sudo sh
sudo service munin-node restart
```

You could then test things out with a sample run:
```
$ sudo munin-run snmp_my-pdu_sentry 
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

On your Munin Master node, add the node to your **/etc/munin/munin.conf** file.  This is explained at http://munin-monitoring.org/wiki/Using_SNMP_plugins.

# Nagios

Stay Tuned.
