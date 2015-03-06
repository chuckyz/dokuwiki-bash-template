# dokuwiki-bash-template
A little bash script that outputs valid Dokuwiki syntax for server documentation

As it stands, this checks for the following:

- Hostname
- Cluster status (via a text file we use internally)
- OS (currently only RHEL/CentOS and friends)
- Drive partition layout
- IP's
- CPU Information
- Total Memory
- Nginx (and|or) Apache version information
- PHP Stats (/etc/trueuserdomains is a cPanel file, but we've adapted it to all servers as a standard)
- PostgreSQL Information (on multiple ports)
- PGBouncer status
- NPM status
- LDAP (via FreeIPA) status
