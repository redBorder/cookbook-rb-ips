module RbIps
  module Helpers
    def get_orgs
      organizations = []

      Chef::Role.list.each_key do |m_key|
        m = Chef::Role.load m_key
        next unless m.override_attributes['redborder'] && m.override_attributes['redborder']['organization_uuid'] && m.override_attributes['redborder']['sensor_uuid'] == m.override_attributes['redborder']['organization_uuid']

        organizations << m
      end
      organizations.each do |org|
        if org.override_attributes && org.override_attributes['redborder'] && org.override_attributes['redborder']['megabytes_limit'].is_a?(String) && org.override_attributes['redborder']['megabytes_limit'].strip.empty?
          org.override_attributes['redborder']['megabytes_limit'] = nil
        end
      end
      organizations
    end
  end
end
