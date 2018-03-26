#
# Regular cron jobs for the artist-sdk package
#
0 4	* * *	root	[ -x /usr/bin/artist-sdk_maintenance ] && /usr/bin/artist-sdk_maintenance
