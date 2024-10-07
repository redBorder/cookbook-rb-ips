module RbIps
  module Helpers
    def load_rb_init_conf
      @rb_init_conf ||= YAML.load_file('/etc/redborder/rb_init_conf.yml')
    end

    def registration_mode
      load_rb_init_conf['registration_mode']
    end

    def get_setup_ip
      conf = load_rb_init_conf
      case registration_mode
      when 'proxy'
        conf['cloud_address']
      when 'manager'
        conf['webui_host']
      end
    end

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

    def update_hosts_file
      setup_ip = get_setup_ip
      reg_mode = registration_mode
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
          grouped_virtual_ips[setup_ip] << bag.gsub('ipvirtual-external-', '')
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
            services_before = services.dup
            services.delete_if { |service| service.split('.').first == service_key }
          end

          # Add running services to localhost
          if new_ip == '127.0.0.1' && running_services.include?(new_service)
            hosts_hash['127.0.0.1'] << "#{new_service}.service"
            next
          end

          # If there is a virtual ip and ips is manager mode
          if new_ip && reg_mode == 'manager'
            hosts_hash[new_ip] << "#{new_service}.service"
            hosts_hash[new_ip] << "#{new_service}.#{node['redborder']['cdomain']}"
          else # Add services with setup_ip
            hosts_hash[setup_ip] << "#{new_service}.service"
            hosts_hash[setup_ip] << "#{new_service}.#{node['redborder']['cdomain']}"
          end
        end
      end

      # Prepare the lines for the hosts file
      hosts_entries = []
      hosts_hash.each do |ip, services|
        format_entry = format('%-18s%s', ip, services.join(' '))
        hosts_entries << format_entry unless services.empty?
      end
      hosts_entries
    end
  end
end


# 127.0.0.1         localhost localhost.localdomain localhost4 localhost4.localdomain4
# ::1               localhost localhost.localdomain localhost6 localhost6.localdomain6
# 10.1.202.214	  data.redborder.cluster rbips-18.node erchef.redborder.cluster rbookshelf.s3.redborder.cluster redborder.cluster s3.service erchef.service http2k.service rb-nils.node f2k.service f2k.redborder.cluster kafka.service kafka.redborder.cluster sfacctd.service sfacctd.redborder.cluster webui.service webui.redborder.cluster
