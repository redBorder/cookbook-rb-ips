#
# Cookbook Name:: ips
# Recipe:: configure_cron_tasks
#
# Copyright 2024, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

cron_d 'create_clean_logs_daily' do
  action :create
  minute '00'
  hour   '00'
  weekday '*'
  retries 2
  ignore_failure true
  command "/usr/lib/redborder/bin/rb_clean_logs_snort.sh"
end