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
  ignore_failure true
  command 'systemctl restart barnyard2 > /dev/null 2>&1'
  action :nothing
end

# Check barnyard2 health
ruby_block 'check_barnyard2_health' do
  block do
    barnyard2_is_enabled = node['redborder']['services']["barnyard2"]
    if barnyard2_is_enabled && !system("/etc/init.d/barnyard2 status > /dev/null 2>&1")
      resources(execute: 'restart_barnyard2').run_action(:run)
    end
  end
  action :nothing
end

# Run the health check at the end of the chef run
at_exit do
  Chef.run_context.resource_collection.find('ruby_block[check_barnyard2_health]').run_action(:run)
end
