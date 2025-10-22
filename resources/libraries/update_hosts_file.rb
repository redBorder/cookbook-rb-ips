module RbIps
  module Helpers
    require 'resolv'

    def external_databag_services
      # This function turned too complex ...
      external_databag = Chef::DataBag.load('rBglobal').keys.grep(/^ipvirtual-external-/)
      services = external_databag.map { |bag| bag.sub('ipvirtual-external-', '') }
      services -= %w(sfacctd) # Excluded for IPS
      services
    end

    def grouped_virtual_ips(manager_registration_ip)
      # Hash where services (from databag) are grouped by ip
      grouped_virtual_ips = Hash.new { |ip, services| ip[services] = [] }
      # Only those visible for IPS. Manager will recognize these services as nginx
      # But erchef and s3 are necessary to access VIPs, so moved to implicit
      nginx_services = %w(http2k webui)

      external_databag_services.each do |bag|
        data = data_bag_item('rBglobal', "ipvirtual-external-#{bag}")
        ip = data['ip'] || manager_registration_ip
        service_name = bag.delete_prefix('ipvirtual-external-')

        services = service_name == 'nginx' ? nginx_services : [service_name]
        grouped_virtual_ips[ip] |= services
      end
      grouped_virtual_ips
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
      hosts_info[manager_registration_ip]['cdomain'] = cdomain
      hosts_info
    end

    # Services not contained in node information
    # Chef needs to know these services to resolve them properly on the first chef run.
    def add_manager_services_info(hosts_info, manager_registration_ip, cdomain)
      implicit_services = [
        "erchef.#{cdomain}",
        "s3.#{cdomain}",
        # Following domains are considered external so we should not include .service...
        # ... But some services might be pointing to these wrong domains. Need to investigate.
        'erchef.service',
        "erchef.service.#{cdomain}",
        's3.service',
        "s3.service.#{cdomain}"
        ###
      ]

      other_services = ['data', 'rbookshelf.s3'].map { |s| "#{s}.#{cdomain}" } # On deprecation.
      hosts_info[manager_registration_ip]['services'] = implicit_services + other_services
      hosts_info
    end

    def add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain)
      is_mode_manager = !node['redborder']['cloud']
      grouped_virtual_ips(manager_registration_ip).each do |ip, services|
        services.each do |service|
          # Add running services to localhost
          next if ip == '127.0.0.1'

          target_ip = ip && is_mode_manager ? ip : manager_registration_ip
          hosts_info[target_ip] ||= {}
          hosts_info[target_ip]['services'] ||= []
          hosts_info[target_ip]['services'] << "#{service}.#{cdomain}"
          # Following services are considered external so we should not include .service
          # ... But some services might be pointing to these wrong domains. Need to investigate.
          hosts_info[target_ip]['services'] << service
          hosts_info[target_ip]['services'] << "#{service}.service" 
          hosts_info[target_ip]['services'] << "#{service}.service.#{cdomain}"
          ###
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
