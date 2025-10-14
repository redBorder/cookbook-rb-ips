module RbIps
  module Helpers
    require 'resolv'

    def get_external_databag_services
      # This function turned too complex ...
      # external_databag = Chef::DataBag.load('rBglobal').keys.grep(/^ipvirtual-external-/)
      # services = external_databag.map { |bag| bag.sub('ipvirtual-external-', '') }
      # services -= %w[sfacctd nginx] # not visible for ips
      # services += ['webui'] # nginx is not visible for ips, while webui is redirected to nginx on the manager
      # services

      # ... so we hardcode the list of services for now
      %w[f2k kafka webui]
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
      implicit_services = ['erchef.service']
      if cdomain
        implicit_services << "erchef.service.#{cdomain}"
        implicit_services << "s3.service.#{cdomain}"
      end
      # Services not contained in node information
      other_services = if cdomain
                         ['data', 'http2k', 'rbookshelf.s3'].map { |s| "#{s}.#{cdomain}" }
                       else
                         []
                       end
      hosts_info[manager_registration_ip]['services'] = implicit_services + other_services
      hosts_info
    end

    def add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain)
      # Hash where services (from databag) are grouped by ip
      grouped_virtual_ips = Hash.new { |hash, key| hash[key] = [] }
      get_external_databag_services.each do |bag|
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
          next if ip == '127.0.0.1'

          target_ip = ip && is_mode_manager ? ip : manager_registration_ip
          hosts_info[target_ip] ||= {}
          hosts_info[target_ip]['services'] ||= []
          hosts_info[target_ip]['services'] << "#{service}.service"
          hosts_info[target_ip]['services'] << "#{service}.service.#{cdomain}"
        end
      end
      hosts_info
    end

    def update_hosts_file
      unless node.dig('redborder', 'resolve_host')
        domain_name = node.dig('redborder', 'manager_registration_ip')
        return {} if domain_name.nil?

        resolved_ip = manager_to_ip(domain_name)
        return {} if resolved_ip.nil?

        node.normal['redborder']['resolve_host'] = resolved_ip
      end
      manager_registration_ip = node.dig('redborder', 'resolve_host')
      return {} unless manager_registration_ip

      cdomain = node.dig('redborder', 'cdomain')

      hosts_info = {}
      hosts_info = add_localhost_info(hosts_info)
      hosts_info = add_manager_names_info(hosts_info, manager_registration_ip, cdomain)
      hosts_info = add_manager_services_info(hosts_info, manager_registration_ip, cdomain)
      add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain) # returns hosts_info
    end
  end
end
