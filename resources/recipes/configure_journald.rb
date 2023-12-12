#
# Cookbook Name:: ips
# Recipe:: configure_journald
#
# Copyright 2024, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

template "/etc/systemd/journald.conf" do
    source "journald.conf.erb"
    owner "root"
    group "root"
    mode 0440
    retries 2
    notifies :restart, 'service[systemd-journald]', :delayed
end

service 'systemd-journald' do
    supports :status => true, :start => true, :restart => true, :reload => true
    action :nothing
end