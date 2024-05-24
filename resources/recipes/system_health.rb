#
# Cookbook:: ips
# Recipe:: prepare_system
#
# Copyright:: 2024, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

# Restart barnyard2 service
execute 'restart_barnyard2' do
  command 'service barnyard2 restart'
  action :nothing
end

# Check services that are not from systemd that should be running
ruby_block 'check_services_health' do
  block do
    is_enabled = node['redborder']['services']["barnyard2"]
    next unless is_enabled
    unless system("/etc/init.d/barnyard2 status > /dev/null 2>&1")
      resources(execute: "restart_barnyard2").run_action(:run)      
    end
  end
  action :nothing
end

# Run the health check at the end of the chef run
at_exit do
  Chef.run_context.resource_collection.find('ruby_block[check_services_health]').run_action(:run)
end
