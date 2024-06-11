# require 'set' TODO: refactor to this
# Default attributes

# general
default['redborder']['cdomain'] = 'redborder.cluster'
default['redborder']['organization_uuid'] = nil
default['redborder']['organizations'] = []
default['redborder']['locations'] = %w(namespace namespace_uuid organization organization_uuid service_provider service_provider_uuid deployment deployment_uuid market market_uuid campus campus_uuid building building_uuid floor floor_uuid)

default['redborder']['ips']['insecure'] = true

# common
default[:redborder][:watchdog][:service] = 'watchdog'
default[:redborder][:smtp][:service] = 'postfix'
default[:redborder][:network] = {}
default[:redborder][:network][:configure_routes] = false
default[:redborder][:network][:routes] = {}
default[:redborder][:chef_enabled] = true
default[:redborder]['proxy'] = {}
default[:redborder]['license'] = {}
default[:redborder]['license']['presence'] = false
default[:redborder]['sshd'] = {}
default[:redborder]['sshd']['addkeys'] = true

# chef-client
default['chef-client']['interval'] = 300
default['redborder']['chef_client_interval'] = 300
default['redborder']['force-run-once'] = false
default['chef-client']['splay'] = 100
default['chef-client']['options'] = ''

# Snort
default['redborder']['snort']['service'] = 'snortd'
default['redborder']['snort']['groups']  = {}

# Barnyard2
default['redborder']['barnyard2']['service'] = 'barnyard2'

# default['redborder']['enable_remote_repo'] = false

# Syslog
default['redborder']['rsyslog']['mode'] = 'extended'

# IPS
default['redborder']['ipsrules'] = {}

# memory
default['redborder']['memory_services'] = {}
default['redborder']['memory_services']['chef-client'] = { 'count': 10, 'memory': 0 }
default['redborder']['memory_services']['snmp'] = { 'count': 5, 'memory': 0, 'max_limit': 10000 }
default['redborder']['memory_services']['redborder-monitor'] = { 'count': 5, 'memory': 0, 'max_limit': 20000 }
default['redborder']['memory_services']['snortd'] = { 'count': 10, 'memory': 0 }
default['redborder']['memory_services']['barnyard2'] = { 'count': 10, 'memory': 0 }

# exclude mem services, setting memory to 0 for each.
default['redborder']['excluded_memory_services'] = ['chef-client']

default['redborder']['services'] = {}
default['redborder']['services']['chef-client'] = true
default['redborder']['services']['redborder-monitor'] = true
default['redborder']['services']['snmp'] = true
default['redborder']['services']['rsyslog'] = true
default['redborder']['services']['snortd'] = true
default['redborder']['services']['barnyard2'] = true

default['redborder']['systemdservices']['chef-client'] = ['chef-client']
default['redborder']['systemdservices']['redborder-monitor'] = ['redborder-monitor']
default['redborder']['systemdservices']['snmp'] = ['snmpd']
default['redborder']['systemdservices']['rsyslog'] = ['rsyslog']
default['redborder']['systemdservices']['snortd'] = ['snortd']
default['redborder']['systemdservices']['barnyard2'] = ['barnyard2']
