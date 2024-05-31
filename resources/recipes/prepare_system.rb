#
# Cookbook Name:: ips
# Recipe:: prepare_system
#
# Copyright 2024, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#
extend Rb_ips::Helpers

#clean metadata to get packages upgrades
execute "Clean yum metadata" do
  command "yum clean metadata"
end

# Stop rb-register
if File.exist?"/etc/redborder/sensor-installed.txt"
  service "rb-register" do
    ignore_failure true
    action [:disable, :stop]
  end
end

#Configure and enable chef-client
dnf_package "redborder-chef-client" do
  flush_cache [:before]
  action :upgrade
end

template "/etc/sysconfig/chef-client" do
  source "sysconfig_chef-client.rb"
  mode 0644
  variables(
    :interval => node["chef-client"]["interval"],
    :splay => node["chef-client"]["splay"],
    :options => node["chef-client"]["options"]
  )
end

if node["redborder"]["services"]["chef-client"]
  service "chef-client" do
    action [:enable, :start]
  end
else
  service "chef-client" do
    action [:stop]
  end
end

cdomain = "redborder.cluster"
#File.open('/etc/redborder/cdomain') {|f| cdomain = f.readline.chomp}
node.default["redborder"]["cdomain"] = cdomain

#get sensors info
node.run_state["sensors_info"] = get_sensors_info()

#get sensors info full info
node.run_state["sensors_info_all"] = get_sensors_all_info()

#get namespaces
node.run_state["namespaces"] = get_namespaces

#memory
#getting total system memory less 10% reserved by system
sysmem_total = (node["memory"]["total"].to_i * 0.90).to_i
#node attributes related with memory are changed inside the function to have simplicity using recursivity
memory_services(sysmem_total)
