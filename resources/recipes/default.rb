#
# Cookbook Name:: ips
# Recipe:: default
#
# Copyright 2022, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

include_recipe 'rb-ips::prepare_system'
include_recipe 'rb-ips::configure'
include_recipe 'rb-ips::configure_cron_tasks'
