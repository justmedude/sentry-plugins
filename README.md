sentry-plugins
==============

Munin and Nagios plugins for a three-phase Server Tech PDU.

# Munin

For Munin: RTFM
http://munin-monitoring.org/wiki/munin-node-configure
http://munin-monitoring.org/wiki/Using_SNMP_plugins

Quick and Dirty:

Assuming your Server Tech PDU is at my-pdu and you've configured SNMP appropriately:

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
```

# Nagios

Stay Tuned.
