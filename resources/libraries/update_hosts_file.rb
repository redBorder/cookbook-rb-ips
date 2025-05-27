module RbIps
  module Helpers
    require 'resolv'

    def external_databag_services
      Chef::DataBag.load('rBglobal').keys.grep(/^ipvirtual-external-/).map { |bag| bag.sub('ipvirtual-external-', '') }
    end

    def read_hosts_file
      hosts_hash = Hash.new { |hash, key| hash[key] = [] }
      File.readlines('/etc/hosts').each do |line|
        next if line.strip.empty? || line.start_with?('#')
        values = line.split(/\s+/)
        ip = values.shift
        services = values
        hosts_hash[ip].concat(services).uniq!
      end
      hosts_hash
    end

    def manager_node_names
      query = Chef::Search::Query.new
      nodes = []
      query.search(:node, 'is_manager:true') do |node|
        nodes << "#{node.name}.node"
      end
      nodes
    end

    def add_localhost_info(hosts_info)
      hosts_info['127.0.0.1'] = {}

      running_services = node.dig('redborder', 'systemdservices')
                             &.values
                             &.flatten
                             &.map { |s| "#{s}.service" } || []
      hosts_info['127.0.0.1']['services'] = running_services
      hosts_info
    end

    def add_manager_names_info(hosts_info, manager_registration_ip, cdomain)
      hosts_info[manager_registration_ip] = {}
      intrusion_node_name = "#{node.name}.node"
      node_names = manager_node_names << intrusion_node_name # append
      hosts_info[manager_registration_ip]['node_names'] = node_names
      hosts_info[manager_registration_ip]['cdomain'] = cdomain if cdomain
      hosts_info
    end

    def add_manager_services_info(hosts_info, manager_registration_ip, cdomain)
      # This services are critical for the use of chef to rewrite the hosts file
      implicit_services = ['erchef.service', 's3.service']
      implicit_services << "erchef.#{cdomain}" if cdomain
      # Services not contained in node information
      other_services = if cdomain
                         %w[data http2k rbookshelf.s3].map { |s| "#{s}.#{cdomain}" }
                       else
                         []
                       end
      hosts_info[manager_registration_ip]['services'] = implicit_services + other_services
      hosts_info
    end

    def add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain)
      # Hash where services (from databag) are grouped by ip
      grouped_virtual_ips = Hash.new { |hash, key| hash[key] = [] }
      external_databag_services.each do |bag|
        virtual_dg = data_bag_item('rBglobal', "ipvirtual-external-#{bag}")
        ip = virtual_dg['ip']
        ip = ip && !ip.empty? ? ip : manager_registration_ip
        grouped_virtual_ips[ip] << bag.gsub('ipvirtual-external-', '')
      end

      is_mode_manager = !node['redborder']['cloud']
      grouped_virtual_ips.each do |ip, services|
        services.uniq! # Avoids having duplicate services in the list
        services.each do |service|
          # Add running services to localhost
          if ip == '127.0.0.1'
            next
          elsif ip && is_mode_manager
            hosts_info[ip] = {} unless hosts_info[ip] # Create if necessary
            hosts_info[ip]['services'] = [] unless hosts_info[ip]['services'] # Create if necessary
            hosts_info[ip]['services'] << "#{service}.service"
            hosts_info[ip]['services'] << "#{service}.#{cdomain}"
          else # default ip
            hosts_info[manager_registration_ip]['services'] << "#{service}.service"
            hosts_info[manager_registration_ip]['services'] << "#{service}.#{node['redborder']['cdomain']}"
          end
        end
      end
      hosts_info
    end

    def gather_hosts_info
      manager_registration_ip = node.dig('redborder', 'manager_registration_ip')
      return {} unless manager_registration_ip

      cdomain = node.dig('redborder', 'cdomain')

      hosts_info = {}
      hosts_info = add_localhost_info(hosts_info)
      hosts_info = add_manager_names_info(hosts_info, manager_registration_ip, cdomain)
      hosts_info = add_manager_services_info(hosts_info, manager_registration_ip, cdomain)
      add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain) # returns hosts_info
    end

    def manager_to_ip(str)
      ipv4_regex = /\A(\d{1,3}\.){3}\d{1,3}\z/
      ipv6_regex = /\A(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}\z/
      dns_regex  = /\A[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/

      return str if str.match?(ipv4_regex) || str.match?(ipv6_regex)
      return Resolv.getaddress(str).to_s if str.match?(dns_regex)

      nil
    end
  end
end
