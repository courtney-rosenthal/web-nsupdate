# web-nsupdate - Dynamic DNS service

The "web-nsupdate" package provides dynamic DNS services for domains
that you serve with the BIND9 DNS server. This allows devices with
dynamic addresses on the Internet, such as a home broadband router,
to have a stable domain name.

**IMPORTANT** -- If you do not have a BIND server already setup and
running then stop now. This package is a front-end service to clients,
allowing them to easily register dynamic DNS changes. It requires a
running back-end service such as BIND9 to manage the DNS.

The service is implemented in PHP and runs under a web server such as
Apache.

Client updates may be performed any of the following ways:

* a DynDNS-compatible client (http://en.wikipedia.org/wiki/DynDNS)
* simple web request, using "curl" or a similar utility
* manual input via built-in web form

The included "ddns-check.sh" script illustrates the second method.
It runs "curl" to perform a DNS update. It's based on a script that
I run periodically (every 5 minutes) on my network, to contact the
"web-nsupdate" service and make updates.

The most recent version has been tested under Debian Linux with the
following packages:

* bind9 (versions 9.7.3, 9.8.4, 9.9.5)
* apache2 (vers 2.2.16, 2.2.22, 2.4.10)
* php5 (vers 5.3.3, 5.4.4, 5.7.17)

See the accompanying INSTALL.md for installation directions.

This package is written by Chip Rosenthal <chip@unicom.com>

The most recent version may be obtaine at: https://github.com/chip-rosenthal/web-nsupdate

