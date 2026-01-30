module RbIps
  module Helpers
    def get_managers_all
      managers = []
      managers_keys = Chef::Node.list.keys.sort
      managers_keys.each do |m_key|
        m = nil
        begin
          m = Chef::Node.load(m_key)
        rescue
          Chef::Log.error("[get_managers_all] Failed to load node: #{m_key}")
        end
        roles = m[:roles] || []
        if roles.include?('manager')
          managers << m
        end
      end
      managers
    end
  end
end
