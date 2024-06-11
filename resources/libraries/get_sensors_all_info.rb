module RbIps
  module Helpers
    def get_sensors_all_info
      sensors_info = {}
      sensor_types = %w(vault-sensor flow-sensor mse-sensor social-sensor scanner-sensor meraki-sensor ale-sensor device-sensor)

      sensor_types.each do |s_type|
        sensors = search(:node, "role:#{s_type} AND redborder_parent_id:#{node['redborder']['sensor_id']}").sort

        sensors_info[s_type] = []
        sensors.each { |s| sensors_info[s_type] << s }
      end

      sensors_info
    end
  end
end
