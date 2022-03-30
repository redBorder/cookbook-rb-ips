
# Configuration file for the chef-client service

CONFIG=/etc/chef/client.rb
PIDFILE=/var/run/chef/client.pid
LOCKFILE=/var/lock/subsys/chef-client
# Sleep interval between runs.
# This value is in seconds.
INTERVAL=<%= @interval %>
# Maximum amount of random delay before starting a run. Prevents every client
# from contacting the server at the exact same time.
# This value is in seconds.
SPLAY=<%= @splay %>
# Any additional chef-client options.
OPTIONS="<%= @options %>"
