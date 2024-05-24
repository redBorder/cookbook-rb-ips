#
# Cookbook:: ips
# Recipe:: system_health
#
# Copyright:: 2024, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

# Check services that are not from systemd that should be running
ruby_block 'check_services_health' do
  block do
    ['barnyard2'].each do |service|
      is_enabled = node['redborder']['services'][service]
      next unless is_enabled
      unless system("/etc/init.d/#{service} status > /dev/null 2>&1")
        restart_output = `/etc/init.d/#{service} restart`
        puts "#{restart_output}"
      end
    end
  end
  action :nothing
end

# Run the health check at the end of the chef run
at_exit do
  Chef.run_context.resource_collection.find('ruby_block[check_services_health]').run_action(:run)
end
