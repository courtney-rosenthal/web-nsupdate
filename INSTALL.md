# web-nsupdate Installation

This document describes the installation procedure for the
_web-nsupdate_ application. You may obtain the package from:
https://github.com/chip-rosenthal/web-nsupdate

Before you begin: you must have a name server (BIND9 or similar) setup
and running. It must be the authoritative name server for the zone(s)
containing the dynamic client(s). For instance, if you want to support
dynamic updates for _my-dsl-modem.example.com_, you must be running the
authoritative name server for _example.com_.


## Install the web-nsupdate_ package

Copy the _web-nsupdate_ files to a location such as
_/usr/local/lib/web-nsupdate_. It's OK to install somewhere else, just
adjust the following directions accordingly.


## Generate the TSIG key

Next, we will generate a TSIG key. It will be used by "web-nsupdate"
to authenticate to the BIND server.

IMPORTANT! Secure this key! Do not leave readable copies around. Somebody
who has a copy of this key can make any changes to the DNS records
associated with this key.

To generate the key:

    cd /usr/local/lib/web-nsupdate/data
    /usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n HOST web-nsupdate
    chmod 440 Kweb-nsupdate.*
    chgrp www-data Kweb-nsupdate.*


## Add the TSIG key to your name server

Next, we will add the secret key that you just generated to your namesever
configuration.

Each key is identified by a name. This key will be used only by the
"web-nsupdate" application, so we'll call it -- unsurprisingly enough --
"web-nsupdate".

You should have a file that has the keys for your name server. On Debian
Linux it is _/etc/bind/bind.keys_. Locate which file is used in your
name server configuration.

The secret key you just created (filename _Kweb-nsupdate.*.private_)
will look something like:

    Private-key-format: v1.3
    Algorithm: 157 (HMAC_MD5)
    Key: V+bGV7H0coxxJT2RBClB6IFetoapDDjEqeKUUwV9mt+ZWOadZ4//+Tsp+WHywdC2TiEFaz0RF89MFEqVMYPNLQ==
    Bits: AAA=
    Created: 20160220193656
    Publish: 20160220193656
    Activate: 20160220193656

The "Key:" field is the secret key value.

Edit the _bind.keys_ file (or whatever it's called on your system)
and add an entry that looks like:

    key web-nsupdate {
        algorithm HMAC-MD5;
        secret "V+bGV7H0coxxJT2RBClB6IFetoapDDjEqeKUUwV9mt+ZWOadZ4//+Tsp+WHywdC2TiEFaz0RF89MFEqVMYPNLQ==";
    };

Replace the "secret" value shown in this example with the actual value
in the secret key you generated.  Don't forget to enclose it in double quotes.

Remember to keep your keys secure. The permissions of your _bind.keys_
file should look something like:

    -r-------- 1 bind bind 633 Oct  6  2012 /etc/lib/bind/bind.keys


## Configure the Host Record for Dynamic Update

Modify your BIND zone data file to grant _web-nsupdate_ access to
update the records associated with dynamic hosts.

If, for example, you want to allow dynamic updates from hosts
"host1.example.com" and "host2.example.com", then modify the "example.com"
zone as shown below:

    --- db.example.com-before   2016-02-20 13:54:16.710061692 -0600
    +++ db.example.com-after    2016-02-20 13:55:08.510227934 -0600
    @@ -1,6 +1,10 @@
         zone "example.com" {
             type master;
             .
             .
             .
    +        update-policy {
    +            grant web-nsupdate. name host1.example.com. A;
    +            grant web-nsupdate. name host2.example.com. A;
    +        };
         };


## Test Dynamic Update

To test that dynamic DNS updates are working, first create an
update data file (let's call it _try.txt_) for testing:

    server localhost
    zone example.com
    update delete host1.example.com
    update add host1.example.com 3600 A 127.0.0.2
    send

Substitute appropriate values for "example.com" and "host1.example.com"
in the above. The 3600 (TTL value) and "127.0.0.2" (host address) values
are arbitrary and were just selected for testing.

You'll need to know the full path to the TSIG key you created earlier
in this note, something like: /usr/local/lib/web-nsupdate/data/Kweb-nsupdate.+157+21176.key

To begin the test, first query the initial value of the host record:

    $ dig @localhost host1.example.com
        .
        .
        .
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 56716
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1
        .
        .
        .

The NXDOMAIN answer indicates that _host1.example.com_ currently is uknown.

Now run the update:

    $ nsupdate -k /usr/local/lib/web-nsupdate/data/Kweb-nsupdate.+157+21176.key <try.txt

Verify that the update was applied:

    $ dig @localhost host1.example.com
        .
        .
        .
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27596
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 3, ADDITIONAL: 4
        .
        .
        .
    ;; ANSWER SECTION:
    host1.example.com.    3600    IN      A       127.0.0.2
        .
        .
        .

Notice that this time the query was successful (status NOERROR) and
one matching record was found (ANSWER: 1). The SOA and address values
in the answer match the values applied in the update. This confirms
the update was successful.


## Create the definitions file

Setup the "web-nsupdate" definitions file, starting with the provided
sample. This file needs to be secured, to protect the client passwords
from being revealed.

	cd /usr/local/lib/web-nsupdate/data
	cp nsupdate-defs.php.sample nsupdate-defs.php
	chmod 640 nsupdate-defs.php
	chgrp www-data nsupdate-defs.php
	vi nsupdate-defs.php

In this example, change "www-data" to whatever group your web server
runs under.


## Test the web-nsupdate

Test the update capability. Point your web browser to the installed
"nsupdate.php" script. This should bring up a form for manual entry.
Submit your entry, and verify the update was successful.


## Debugging

(This section is out of date and needs to be revised.)

If web-nsupdate fails, it will return an error message in an HTML
document. Some of the common errors and their likely solutions are:

### Failed opening required '/usr/local/lib/web-nsupdate/data/nsupdate-defs.php'

Fix the require_once() statement in "nsupdate.php" so that it
can find the definitions file.

### Host "router.example.com" unknown.

Add an entry for this host to the $Hosts_Table list in "nsupdate-defs.php".

### Permission denied.

Check that the password used matches the one listed in the
$Hosts_Table entry for this host.

### could not read key from /usr/local/lib/web-nsupdate/Kweb-nsupdate.+157+61241.key

Verify that the DEFAULT_NSKEY definition in your "nsupdate-defs.php"
file has the correct path to your TSIG key. Verify that both the ".key"
and ".private" files are available in that directory and readable by
the web server (but, preferably, not the world).

