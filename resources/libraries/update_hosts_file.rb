module RbIps
  module Helpers
    require 'resolv'

    def get_external_databag_services
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
      node_names = []
      query.search(:node, 'is_manager:true') do |node|
        node_names << "#{node.name}.node"
      end
      node_names
    end

    def update_hosts_file
      unless node.dig('redborder', 'resolve_host')
        domain_name = node.dig('redborder', 'manager_registration_ip')
        return if domain_name.nil?
        resolved_ip = manager_to_ip(domain_name)
        return if resolved_ip.nil?
        node.normal['redborder']['resolve_host'] = resolved_ip
      end
      manager_registration_ip = node.dig('redborder', 'resolve_host')
      # Up until here, we resolved and stored the ip for /etc/hosts only if necessary

      running_services = node['redborder']['systemdservices'].values.flatten if node['redborder']['systemdservices']
      databags = get_external_databag_services
      hosts_hash = read_hosts_file

      # Hash where services (from databag) are grouped by ip
      grouped_virtual_ips = Hash.new { |hash, key| hash[key] = [] }
      databags.each do |bag|
        virtual_dg = data_bag_item('rBglobal', "ipvirtual-external-#{bag}")
        ip = virtual_dg['ip']

        if ip && !ip.empty?
          grouped_virtual_ips[ip] << bag.gsub('ipvirtual-external-', '')
        else
          grouped_virtual_ips[manager_registration_ip] << bag.gsub('ipvirtual-external-', '')
        end
      end

      # Add running services to localhost
      grouped_virtual_ips['127.0.0.1'] ||= []
      running_services.each { |serv| grouped_virtual_ips['127.0.0.1'] << serv }

      # Group services
      grouped_virtual_ips.each do |new_ip, new_services|
        new_services.each do |new_service|
          # Avoids having duplicate services in the list
          service_key = new_service.split('.').first
          hosts_hash.each do |_ip, services|
            services.delete_if { |service| service.split('.').first == service_key }
          end

          # Add running services to localhost
          if new_ip == '127.0.0.1' && running_services.include?(new_service)
            hosts_hash['127.0.0.1'] << "#{new_service}.service"
            next
          end

          # If there is a virtual ip and ips is manager mode
          if new_ip && !node['redborder']['cloud']
            hosts_hash[new_ip] << "#{new_service}.service"
            hosts_hash[new_ip] << "#{new_service}.#{node['redborder']['cdomain']}"
          else # Add services with manager_registration_ip
            hosts_hash[manager_registration_ip] << "#{new_service}.service" #kafka.service
            hosts_hash[manager_registration_ip] << "#{new_service}.#{node['redborder']['cdomain']}"
          end
        end
      end

      # merge services of manager IP with manager node names
      hosts_hash[manager_registration_ip] = (hosts_hash[manager_registration_ip] || []) + manager_node_names

      # Prepare the lines for the hosts file
      hosts_entries = []
      hosts_hash.each do |ip, services|
        format_entry = format('%-18s%s', ip, services.join(' '))
        hosts_entries << format_entry unless services.empty?
      end
      hosts_entries
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
