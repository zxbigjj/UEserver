#chmod 644 'rsyncd.secrets'
#chown root 'rsyncd.secrets'
rsync --daemon --config rsyncd.conf
