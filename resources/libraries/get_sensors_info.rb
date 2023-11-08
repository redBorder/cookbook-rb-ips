module Rb_ips
    module Helpers
      def get_sensors_info()
        sensors_info = {}
        sensor_types = ["vault-sensor","flow-sensor","mse-sensor","social-sensor","scanner-sensor","meraki-sensor","ale-sensor", "device-sensor"]
        locations = node["redborder"]["locations"] rescue {}
  
  
        sensor_types.each do |s_type|
          sensors = search(:node, "role:#{s_type} AND redborder_parent_id:#{node["redborder"]["sensor_id"]}").sort
          info = {}
          found_sensor = false
  
          sensors_info[s_type] = {}
          sensors.each do |s|
            found_sensor = true
            info["name"] = s.name
            info["ip"] = s["ipaddress"]
            info["sensor_uuid"] = s["redborder"]["sensor_uuid"] if !s["redborder"]["sensor_uuid"].nil?
            info["organization_uuid"] = s["redborder"]["organization_uuid"] if !s["redborder"]["organization_uuid"].nil?
            info["megabytes_limit"] = s["redborder"]["megabytes_limit"] if !s["redborder"]["megabytes_limit"].nil?
            info["index_partitions"] = s["redborder"]["index_partitions"] if !s["redborder"]["index_partitions"].nil?
            info["index_replicas"] = s["redborder"]["index_replicas"] if !s["redborder"]["index_replicas"].nil?
            info["sensors_mapping"] = s["redborder"]["sensors_mapping"] if !s["redborder"]["sensors_mapping"].nil?
            info["locations"] = {}
            locations.each do |loc|
              if !s["redborder"][loc].nil?
                info["locations"][loc] = s["redborder"][loc]
              end
            end
            sensors_info[s_type][s.name] = info if found_sensor
          end
        end
        return sensors_info
      end
    end
  end
  