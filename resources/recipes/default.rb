#
# Cookbook Name:: ips
# Recipe:: default
#
# Copyright 2024, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

include_recipe 'rb-ips::prepare_system'
include_recipe 'rb-ips::configure'
include_recipe 'rb-ips::configure_cron_tasks'
include_recipe 'rb-ips::configure_journald'