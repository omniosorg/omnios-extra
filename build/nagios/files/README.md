Nagios 4.x
==========

Nagios is a host/service/network monitoring program written in C and released under the GNU General Public License, version 2. CGI programs are included to allow you to view the current status, history, etc via a web interface if you so desire.

Visit the Nagios homepage at https://www.nagios.org for documentation, new releases, bug reports, information on discussion forums, and more.

Nagios Installation on OmniOS
-----------------------------

#### Install and Configure

    pkg install fcgiwrap nagios nagios-plugins nginx php-74
    usermod -G fcgiwrap nginx
    usermod -G nagcmd fcgiwrap
    cp nagios-nginx-example.conf /etc/opt/ooce/nginx/nginx.conf

#### Setup htpasswd Authorization

As the Apache *httpasswd* program is not available, it is possible to create the *htpasswd* file as follows:

    echo -e "nagiosadmin:`perl -le 'print crypt("your_password","salt")'`" > /opt/ooce/nginx/htpasswd.users

#### Start Nagios

    svcadm enable php74
    svcadm enable fcgiwrap
    svcadm enable nginx
    svcadm enable nagios

Testing the Installation
------------------------

You can now monitor Nagios by accessing the Web Interface:

    http://nagios.$hostname

