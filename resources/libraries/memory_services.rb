module RbIps
  module Helpers
    def memory_services(sysmem_total, excluded_services = [])
      memory_serv = {}
      memory_services_size = 0
      memory_services_size_total = 0
      memlimit_found = false
      sysmem_total_limitsless = nil

      node['redborder']['memory_services'].each do |name, mem_s|
        if node['redborder']['services'][name] &&
           !excluded_services.include?(name) &&
           !node['redborder']['excluded_memory_services'].include?(name)
          memory_services_size += mem_s['count']
        end

        memory_services_size_total += mem_s['count']
      end # end do

      if memory_services_size <= 0
        memory_services_size = memory_services_size_total > 0 ? memory_services_size_total : 1
      end

      node['redborder']['memory_services'].each do |name, mem_s|
        next unless node['redborder']['services'][name] && !excluded_services.include?(name)

        next unless !node['redborder']['excluded_memory_services'].include?(name)

        # service count memory assigned * system memory / assigned services memory size
        memory_serv[name] = (mem_s['count'] * sysmem_total / memory_services_size).round

        # if the service has a limit of memory, we have to recalculate all using recursivity
        next unless mem_s['max_limit'] && memory_serv[name] > mem_s['max_limit']

        memlimit_found = true
        excluded_services << name
        # assigning the limit of memory for this service
        node.default['redborder']['memory_services'][name]['memory'] = mem_s['max_limit']
        # now we have to take off the memory excluded from the total to recalculate memory wihout excluded services by limit
        sysmem_total_limitsless = sysmem_total - mem_s['max_limit']
      end

      if memlimit_found
        # Function that call itself with services excluded for recalculate memory
        memory_serv = memory_services(sysmem_total_limitsless, excluded_services)
      else
        memory_serv.each do |name, memory|
          node.default['redborder']['memory_services'][name]['memory'] = memory
        end
      end
    end
  end
end
