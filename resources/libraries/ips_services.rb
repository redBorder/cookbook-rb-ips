class Chef
  class Recipe
    def ips_services
      ips_services = {}
      if node['redborder']['services']
        node['redborder']['services'].each do |k, v|
          if v == true || v == false
            ips_services[k] = v
          end
        end
      end

      # changing default values in case of the user has modify them
      if node['redborder']['services']['overwrite']
        node['redborder']['services']['overwrite'].each do |k, v|
          if v == true || v == false
            ips_services[k] = v
          end
        end
      end

      begin
        file_services = JSON.parse(File.read('/etc/redborder/services.json'))
      rescue Errno::ENOENT, JSON::ParserError => e
        Chef::Log.warn("Error loading services from file: #{e.message}")
        file_services = {}
      end

      systemd_services = node.attributes['redborder']['systemdservices']
      systemd_services.each do |service_name, systemd_name|
        sys_name = systemd_name.join(',')
        if file_services.key?(sys_name)
          ips_services[service_name] = file_services[sys_name]
        end
      end

      ips_services
    end
  end
end
