# Cookbook:: ips
# Recipe:: prepare_system
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

# Restart barnyard2 service
execute 'restart_barnyard2' do
  ignore_failure true
  command 'systemctl restart barnyard2 > /dev/null 2>&1'
  action :nothing
end

# Add manager node ip addr to /etc/hosts
ruby_block 'update_hosts_file_if_needed' do
  block do
    def managerToIp(str)
      ipv4_regex = /\A(\d{1,3}\.){3}\d{1,3}\z/
      ipv6_regex = /\A(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}\z/
      dns_regex = /\A[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/

      return str if str =~ ipv4_regex || str =~ ipv6_regex

      if str =~ dns_regex
        ip = `dig +short #{str}`.strip
        return ip unless ip.empty?
      end
    end

    unless node['redborder']['cloud']
      # Read webui_host from the rb_init_conf.yml file
      webui_host_command = "grep '^webui_host:' /etc/redborder/rb_init_conf.yml | awk '{print $2}'"
      webui_host = managerToIp `#{webui_host_command}`.strip

      # Search for a node matching the webui_host IP address
      matching_node_name = search(:node, "ipaddress:#{webui_host}").first&.name

      # Update /etc/hosts if a matching node is found
      if matching_node_name
        node_name_with_suffix = "#{matching_node_name}.node"
        hosts_file = '/etc/hosts'

        unless ::File.readlines(hosts_file).grep(/#{Regexp.escape(node_name_with_suffix)}/).any?
          ::File.open(hosts_file, 'a') { |file| file.puts "#{webui_host} #{node_name_with_suffix}" }
        end
      end
    end
  end
  action :run
end

# Check barnyard2 health
ruby_block 'check_barnyard2_health' do
  block do
    barnyard2_is_enabled = node['redborder']['services']['barnyard2']
    if barnyard2_is_enabled && !system('/etc/init.d/barnyard2 status > /dev/null 2>&1')
      resources(execute: 'restart_barnyard2').run_action(:run)
    end
  end
  action :nothing
end

# Run the health check at the end of the chef run
at_exit do
  Chef.run_context.resource_collection.find('ruby_block[check_barnyard2_health]').run_action(:run)
end
