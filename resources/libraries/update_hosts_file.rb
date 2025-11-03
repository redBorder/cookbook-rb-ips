module RbIps
  module Helpers
    # Gets the list of databags related with external services in interest
    # Returns the list of databags the IPS needs to consider, in format []
    def fetch_vip_databags
      databags = []
      begin
        databags = Chef::DataBag.load('rBglobal').keys.select { |s| s.include?('ipvirtual-external-') && !s.include?('sfacctd') }
      rescue e
        Chef::Log.warn 'No databags found in update hosts.'
      end
      databags
    end

    # Map databag-related services to their corresponding IPs in the resolution map
    # INPUT: The ip of the manager is set by default if the virtual ip isn't declared yet.
    # Returns a map of <virtual_ip => services[]> with the external vips
    def grouped_virtual_ips(manager_registration_ip)
      ip_services = Hash.new { |ip, services| ip[services] = [] }

      vip_databags = fetch_vip_databags
      vip_databags.each do |bag|
        data = data_bag_item('rBglobal', bag)
        ip = data['ip'] || manager_registration_ip
        services =
          if bag == 'ipvirtual-external-nginx'
            %w(http2k webui) # Services redirected by nginx
          else
            [bag.delete_prefix('ipvirtual-external-')]
          end

        ip_services[ip] = services
      end
      ip_services
    end

    # Gets nodes on the format of <hostname>.node of very manager in the cluster.
    # Returns the names as an array of strings
    def fetch_node_names
      nodes = []
      Chef::Search::Query.new.search(:node, 'is_manager:true') do |node|
        nodes << "#{node.name}.node"
      end
      nodes
    end

    # Creates relation between localhost and sevices running on it
    # INPUT: Reference of the ip=>domains map on build
    # Returns the reference of the map with the additional info
    def add_localhost_info(hosts_info)
      hosts_info['127.0.0.1'] = {}

      running_services = node.dig('redborder', 'systemdservices')
                             &.values
                             &.flatten
                             &.map { |s| "#{s}.service" } || []
      hosts_info['127.0.0.1']['services'] = running_services
      hosts_info
    end

    # Adds to input map nodes in consideration: managers and the proper IPS
    # INPUT:
    #   hosts_info: Reference of the ip=>domains map on build
    #   manager_registration_ip: The ip of the manager where the IPS was registered
    #   cdomain: The cdomain defined on installation of the manager/cluster
    # Returns the reference of the map with the additional info
    def add_manager_names_info(hosts_info, manager_registration_ip, cdomain)
      hosts_info[manager_registration_ip] = {}
      ips_node_name = "#{node.name}.node"
      manager_node_names = fetch_node_names
      node_names = manager_node_names << ips_node_name # append
      hosts_info[manager_registration_ip]['node_names'] = node_names
      hosts_info[manager_registration_ip]['cdomain'] = cdomain
      hosts_info
    end

    # Adds the services needed to make cookbooks like this apply the domain resolution
    # properly. Notice that this function depends on the implicit resolution of
    # erchef and s3 are necessary, so that's why we add them to keep them on the update.
    # INPUT:
    #   hosts_info: Reference of the ip=>domains map on build
    #   manager_registration_ip: The ip of the manager where the IPS was registered
    #   cdomain: The cdomain defined on installation of the manager/cluster
    # Returns the reference of the map with the additional info
    def add_manager_services_info(hosts_info, manager_registration_ip, cdomain)
      implicit_services = [
        "erchef.#{cdomain}",
        "s3.#{cdomain}",
        'erchef.service',
        "erchef.service.#{cdomain}",
        's3.service',
        "s3.service.#{cdomain}",
      ]

      other_services = ['data', 'rbookshelf.s3'].map { |s| "#{s}.#{cdomain}" } # On deprecation.
      hosts_info[manager_registration_ip]['services'] = implicit_services + other_services
      hosts_info
    end

    # Adds the external services that can have virtual ips. If no virtual ip is assigned
    # yet, the manager ip would be used by default.
    # INPUT:
    #   hosts_info: Reference of the ip=>domains map on build
    #   manager_registration_ip: The ip of the manager where the IPS was registered
    #   cdomain: The cdomain defined on installation of the manager/cluster
    # Returns the reference of the map with the additional info
    def add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain)
      is_mode_manager = !node['redborder']['cloud']
      ip_services = grouped_virtual_ips(manager_registration_ip)

      ip_services.each do |ip, services|
        services.each do |service|
          next if ip == '127.0.0.1'

          target_ip = ip && is_mode_manager ? ip : manager_registration_ip
          hosts_info[target_ip] ||= {}
          hosts_info[target_ip]['services'] ||= []
          hosts_info[target_ip]['services'] << "#{service}.#{cdomain}"
          # Following services are considered external so we should not include .service
          # ... But some services might be pointing to these wrong domains. Need to investigate.
          hosts_info[target_ip]['services'] << "#{service}.service"
          hosts_info[target_ip]['services'] << "#{service}.service.#{cdomain}"
        end
      end
      hosts_info
    end

    # Main function that creates a ruby logic hash map of ip => domains to be reading by
    # /etc/hosts template. The function is subdivided based on the logic location
    # and the nature of the domain, some are services in localhost, others node names.
    # Returns the complete map that is going to be put in /etc/hosts in hash map format,
    # where keys are the ips and values are the domains in array of strings format.
    def update_hosts_file
      hosts_info = Hash.new { |_ip, _domains| }

      unless node.dig('redborder', 'resolve_host')
        domain_name = node.dig('redborder', 'manager_registration_ip')
        return hosts_info if domain_name.nil?

        resolved_ip = manager_to_ip(domain_name)
        return hosts_info if resolved_ip.nil?

        node.normal['redborder']['resolve_host'] = resolved_ip
      end
      manager_registration_ip = node.dig('redborder', 'resolve_host')
      return hosts_info unless manager_registration_ip

      cdomain = node.dig('redborder', 'cdomain')

      add_localhost_info(hosts_info)
      add_manager_names_info(hosts_info, manager_registration_ip, cdomain)
      add_manager_services_info(hosts_info, manager_registration_ip, cdomain)
      add_virtual_ips_info(hosts_info, manager_registration_ip, cdomain)
      hosts_info
    end
  end
end
