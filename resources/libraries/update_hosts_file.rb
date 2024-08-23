module RbIps
  module Helpers
    def update_hosts_file
      managers = get_managers_all()
      manager_ip = []
      managers.each do |m|
        manager_ip << m['ipaddress_sync']
      end

      # grouped_virtual_ips returns a hash where:
      # - The keys are IP addresses from the data bags, or `nil` if an IP is missing.
      # - The values are arrays of services associated with each IP address.
      # - If an IP is missing from a data bag, the associated services are grouped under the sync_ip key.
      grouped_virtual_ips = Hash.new { |hash, key| hash[key] = [] }
      databags = Chef::DataBag.load('rBglobal').keys
      databags.each do |bag|
        next unless bag.start_with?('ipvirtual-external')
        virtual_dg = data_bag_item('rBglobal', bag)
        ip = virtual_dg['ip']

        if ip && !ip.empty?
          grouped_virtual_ips[ip] << bag.gsub('ipvirtual-external-', '')
        else
          grouped_virtual_ips[manager_ip[0]] << bag.gsub('ipvirtual-external-', '')
        end
      end

      # Read hosts file and store in hash
      hosts_hash = Hash.new { |hash, key| hash[key] = [] }
      File.readlines('/etc/hosts').each do |line|
        next if line.strip.empty? || line.start_with?('#')
        values = line.split(/\s+/)
        ip = values.shift
        services = values
        hosts_hash[ip].concat(services).uniq!
      end

      # Update hosts_hash based on grouped_virtual_ips
      grouped_virtual_ips.each do |new_ip, new_services|
        new_services.each do |new_service|
          service_key = new_service.split('.').first

          hosts_hash.each do |_ip, services|
            services.delete_if { |service| service.split('.').first == service_key }
          end

          if new_ip
            hosts_hash[new_ip] << "#{new_service}.service"
            hosts_hash[new_ip] << "#{new_service}.#{node['redborder']['cdomain']}"
          else
            hosts_hash[manager_ip[0]] << "#{new_service}.service"
            hosts_hash[manager_ip[0]] << "#{new_service}.#{node['redborder']['cdomain']}"
          end
        end
      end

      # Prepare the lines for the hosts file
      hosts_entries = []
      hosts_hash.each do |ip, services|
        hosts_entries << "#{ip} #{services.join(' ')}" unless services.empty?
      end

      hosts_entries
    end
  end
end
