module RbIps
  module Helpers
    def joinHostArray2port(hosts, port)
      hosts.map { |host| host << ':' << port.to_s }

      hosts
    end
  end
end
