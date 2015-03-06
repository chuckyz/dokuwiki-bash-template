#!/bin/bash

############################################
#  DokuWiki Server page generator          #
#  Author: Charles Z.                      #
#  Email: charlesz@focusschoolsoftware.com #
#  Note: Attempted to keep as generic as   #
#  possible, but we have some strange      #
#  conventions here and there.  They have  #
#  been noted where it matters.            #
############################################
####  Maintaining Key: ####
####
#  Master section:
#  echo "==== NAME ====";
####
#  Subsection:
#  echo "=== SECTION ===";
####
#  Multiple subsections?
#  echo "----";
#  subsections
#  echo "";
#  echo "----";
####
#  Output for unordered list
#  echo "   * foobar";
####
#  Need to loop?
#  echo "==== SECTION ===="; var=$(some_command | grep foo); for i in $var; do echo "   * $i"; done;
####
############################
####  File conventions used: ####
####
#  /etc/clustername : a file that should either exist, with a single line of text for the name of the cluster, or should not exist at all.
####
#  /etc/trueuserdomains : a list of all available users on the server.  *Should* only be PHP users.
####
#  tmpfile : Use this name for a file if you need to pipe any temporary output to a file.  Ensure to remove it with
#  rm -f tmpfile 2> /dev/null : We don't care about errors in this script.
####
############################


#Output Hostname
echo "==== Hostname ===="
echo "   * `hostname`"

#Part of a cluster?
echo "==== Cluster ====";
if [ -f /etc/clustername ]; then
	echo "   * `cat /etc/clustername`";	
else
	echo "   * `hostname` is not part of a cluster.";
fi

#Output Linux OS Version
echo "==== OS ===="
echo "   * `cat /etc/redhat-release`"

#Output Drive layout
echo "==== Partitons ====";
echo "`df -h | awk '{print $1,$6}' | sed 's/ / \| /;s/$/ \|/;s/^/\| /' | sed '1s/.*/\^ Filesystem \^ Mounted \^/g'`";

#Output IP's
echo "==== IPs ===="; ips=$(ifconfig | grep -A1 "eth0\|eth1" | awk '/inet/ {print substr($2,6)}'); for i in $ips; do echo "   * $i"; done;

#Output total thread-count, type, and whatnot
echo "==== CPU Information ====";
echo "----";
echo "=== CPU Model ===";
echo "   * `cat /proc/cpuinfo  | grep 'model name' | head -1 | cut -f2- -d: | cut -f-1 -d\@`";
echo "=== CPU Speed (MHz) ===";
echo "   * `cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}' | cut -f1 -d.`";
echo "=== Total Threads (Cores) ===";
echo "   * `cat /proc/cpuinfo  | grep processor | wc -l`";
echo "";
echo "----";

#Output memory stats (only total... it's always ECC anyway)
echo "==== Total Memory ====";
echo "   * `free -mt | awk '/Mem/ {print $2"\""MB"\""}'`";

#Check for nginx or apache
#Note!! Some servers have both installed, getting them both isn't wrong!

#Output Apache stats
ps faux | grep 'httpd' | grep -v grep &> /dev/null
if [ $? == 0 ]; then
	echo "==== Apache Stats ====";
	httpd -v | while read i; do echo "   * $i"; done;
fi

#Output Nginx stats
ps faux | grep 'nginx' | grep -v grep &> /dev/null
if [ $? == 0 ]; then
	echo "==== Nginx Stats ====";
	echo "   * Version: `nginx -v 2>&1 | cut -f2 -d/`";
fi

#Output PHP stats
echo "==== PHP =====";
echo "----";
echo "=== PHP Version ===";
echo "   * `php -v | awk '/cli/ {print $2}'`"
echo "=== PHP Modules ==="; phpmodules=$(php -m | grep -v '\['); for i in $phpmodules; do echo "   * $i"; done;
echo "=== PHP Users ==="; phpusers=$(cat /etc/trueuserdomains | awk '{print $2}'); for i in $phpusers; do echo "   * $i"; done;
echo "";
echo "----";

#Output PostgreSQL stats
echo "==== PostgreSQL Information ====";
echo "----";
echo -e "5432\n5433" >> tmpfile
for i in `cat tmpfile`;
do psql -Upostgres -p$i -t -c"SHOW SERVER_VERSION" | head -1 &> /dev/null;
  if [ $? == 0 ]; then
        echo "=== PostgreSQL Port $i ===="
        echo "   * Version: `psql -Upostgres -p$i -t -c"SHOW SERVER_VERSION" | head -1`";
        echo "   * Data Directory: `psql -Upostgres -p$i -t -c"SHOW data_directory" | head -1`";
 fi;
done;
rm -f tmpfile 2> /dev/null
echo "";
echo "----";

#pgbouncer?
ps faux | grep pgbouncer &> /dev/null
if [ $? == 0 ]; then
	echo "==== PGBouncer ====";
	echo "   * PGBouncer is installed";
else
	echo "==== PGBouncer ====";
	echo "   * PGBouncer is not installed";
fi

#NPM?
npm &> /dev/null
if [ $? == 0 ]; then
	echo "==== NPM ====";
	echo "   * NPM is installed";
else
	echo "==== NPM ====";
	echo "   * NPM is not installed";
fi

#LDAP?
rpm -q ipa-client &> /dev/null
if [ $? == 0 ]; then
	echo "==== LDAP ====";
	echo "   * LDAP Logins are enabled";
else
	echo "==== LDAP ====";
	echo "   * LDAP Logins are disabled";
fi


