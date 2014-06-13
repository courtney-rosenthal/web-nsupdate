# web-nsupdate - Dynamic DNS service

The "web-nsupdate" package provides dynamic DNS services for domains
that you serve with the BIND9 DNS server. This allows devices with
dynamic addresses on the Internet, such as a home broadband router,
to have a stable domain name.

**IMPORTANT** -- If you do not have a BIND server already setup
and running then stop now. You need to have a BIND server running,
configured to do dynamic DNS updates. This package merely provides a
front-end service to clients.

The service is implemented in PHP and runs under a web server such as
Apache. It requires access to the BIND server that is authoritative to
the domain.

Client updates may be performed any of the following ways:

* a DynDNS-compatible client (http://en.wikipedia.org/wiki/DynDNS)
* simple (RESTful) web request, using "curl" or a similar utility
* manual input via built-in web form

The included "ddns-check.sh" script is based on a script that I
run periodically (every 5 minutes) on my network, to contact the
"web-nsupdate" service and make updates.

The most recent version has been tested under Debian Linux with the
following packages:

* bind9 (versions 9.7.3, 9.8.4)
* apache2 (ver 2.2.16, 2.2.22)
* php5 (ver 5.3.3, 5.4.4)


## Server Installation Directions

It is not easy setting up your local BIND server to do dynamic DNS.
I'll take a shot at describing that process here. I *strongly* urge you
to review the dnssec-keygen(8) and nsupdate(8) man pages first, so you
can get some idea of what we are trying to accomplish.

These directions assume you are installing the package in a directory
"/usr/local/lib/web-nsupdate". You can install the package anywhere,
just adjust the paths accordingly.

In the example below, group "www-data" is used to represent the group
that your web server operates under. (That's what Debian Linux does.)
If your web server uses some different group, substitute that instead.

### Install the package

Copy the "web-nsupdate" files to a location such as
"/usr/local/lib/web-nsupdate".  It is OK to install somewhere else,
just adjust the following directions accordingly. There

### Generate the TSIG key

Generate a TSIG key that "web-nsupdate" will use to authenticate itself
to the DNS server.

Secure this key! Do not leave readable copies around. This key can be
used to make changes to DNS records managed by "web-nsupdate".

Here are the steps to generate the key:

    cd /usr/local/lib/web-nsupdate/data
    /usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n HOST web-nsupdate
    chmod 440 Kweb-nsupdate*
    chgrp www-data Kweb-nsupdate*

In this example, change "www-data" to whatever group your web server
runs under.

Be patient. On my Core 2 Duo 2.66GHz server, dnssec-keygen takes 1:40
to execute.

### Create the definitions file

Setup the "web-nsupdate" definitions file, starting with the provided
sample.  This file needs to be secured, to protect the client passwords
from being revealed.

	cd /usr/local/lib/web-nsupdate/data
	cp nsupdate-defs.php.sample nsupdate-defs.php
	chmod 640 nsupdate-defs.php
	chgrp www-data nsupdate-defs.php
	vi nsupdate-defs.php

In this example, change "www-data" to whatever group your web server
runs under.

### Install into your web server

Install the nsupdate.php script into your web server.

If, for instance, you wish to install it into the document
directory at /var/www, then do:

    ln -s /usr/local/lib/web-nsupdate/nsupdate.php /var/www
    
At this point, the "web-nsupdate" front-end is configured.  Now to configure
the nameserver back-end.

### Configure BIND for dynamic DNS

Assuming you don't already have a place for nameserver keys, create a
new file called "named.keys" that contains the TSIG key just created for
"web-nsupdate" to use.

The file will look something like:

	key web-nsupdate {
		algorithm HMAC-MD5;
		secret "jzzoM.....Ewg44Q==";
	};
	
The "secret" will be a very long string. It's truncated here for display.

Install the "named.keys" file to the directory where your "named.conf"
resides.  This file needs to be secured, to protect your namesever
from unauthorized updates.
If your "named.conf" directory is "/etc/bind", do:

	mv named.keys /etc/bind/named.keys
	chmod 400 /etc/bind/named.keys
	chown bind:bind /etc/bind/named.keys

In this example, adjust "bind:bind" to the user and group ids that your
nameserver runs under.

Add a line to your "named.conf" that says:

	include "named.keys";

Modify your "named.conf" to list each host that web-nsupdate will be
updating.  If, for example, you want to allow dynamic updates from hosts
"host1.example.com" and "host2.example.com", then modify the "example.com"
stanza in "named.conf" and add two lines:

	zone "example.com" {
		type master;
		.
		.
		.
		# add the lines below, one per host in thie zone
		update-policy {
			grant web-nsupdate. name host1.example.com. A;
			grant web-nsupdate. name host2.example.com. A;
		};
	};

=== Test the update capability

Test the update capability.  Point your web browser to the installed
"nsupdate.php" script.  This should bring up a form for manual entry.
Submit your entry, and verify the update was successful.

== Debugging

(This section is out of date and needs to be revised.)

If web-nsupdate fails, it will return an error message in an HTML
document.  Some of the common errors and their likely solutions are:

=== Failed opening required '/usr/local/lib/web-nsupdate/data/nsupdate-defs.php'

Fix the require_once() statement in "nsupdate.php" so that it
can find the definitions file.

=== Host "router.example.com" unknown.

Add an entry for this host to the $Hosts_Table list in "nsupdate-defs.php".

=== Permission denied.

Check that the password used matches the one listed in the
$Hosts_Table entry for this host.

=== could not read key from /usr/local/lib/web-nsupdate/Kweb-nsupdate.+157+61241.key

Verify that the DEFAULT_NSKEY definition in your "nsupdate-defs.php"
file has the correct path to your TSIG key.  Verify that both the ".key"
and ".private" files are available in that directory and readable by
the web server (but, preferably, not the world).

=== other nsupdate issues

Review BIND configuration.


== The fine print

Copyright 2005-2014, Chip Rosenthal <chip@unicom.com>.

See software license at <http://www.unicom.com/sw/license.html>
for terms of use and distribution.
