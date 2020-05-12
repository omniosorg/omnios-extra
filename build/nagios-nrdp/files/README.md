NRDP 2.x
========

NRDP (Nagios Remote Data Processor) is a simple, PHP-based passive result collector for use with Nagios. It is designed to be a flexible data transport mechanism and processor, with a simple and powerful architecture that allows for it to be easily extended and customized to fit individual users' needs.

By default, NRDP has the capability of allowing remote agents, applications, and Nagios instances to submit commands and host and service check results to a Nagios server. This allows Nagios administrators to use NRDP to configure distributed monitoring, passive checks, and remote control of their Nagios instance in a quick and efficient manner. The capabilities for NRDP can be extended through the development of additional NRDP plugins.

NRDP Installation on OmniOS
---------------------------

#### Install and Configure

Prerequisite:  Nagios installed and working.

    svcadm disable nagios
    svcadm disable nginx
    svcadm disable php74
    pkg install nrdp
    usermod -G nagcmd php
    usermod -G nagcmd nagios
    cp nrdp-nginx-example.conf /etc/opt/ooce/nginx/nginx.conf

#### Setup NRDP Token

A client request must contain a valid token in order for the NRDP to respond or honor the request. Edit `/opt/ooce/nrdp/config.inc.php` to add a token.

> **NOTE:** Tokens are just alphanumeric strings - make them hard to guess!

#### Start NRDP

    svcadm enable php74
    svcadm enable nginx
    svcadm enable nagios

Testing the Installation
------------------------

You can now try out the NRDP server API example by accessing:

    http://nrdp.$hostname

Submmitting Check Results
-------------------------

You don't need to use the NRDP client scripts to submit check results. Check results can be submitted using a http post request using a client like *curl*. Both XML and JSON formats are supported. See the `send_nrdp-example.sh` for an example.

