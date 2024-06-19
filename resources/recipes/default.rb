# Cookbook:: ips
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

include_recipe 'rb-ips::prepare_system'
include_recipe 'rb-ips::configure'
include_recipe 'rb-ips::configure_cron_tasks'
include_recipe 'rb-ips::configure_journald'
include_recipe 'rb-ips::system_health'
