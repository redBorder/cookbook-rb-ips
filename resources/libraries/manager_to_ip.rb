module RbIps
  module Helpers
    # resolves an ip as the same ip
    # resolves domain as ip if it can be resolved
    # otherwise returns nil
    def manager_to_ip(str)
      ipv4_regex = /\A(\d{1,3}\.){3}\d{1,3}\z/
      ipv6_regex = /\A(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}\z/
      dns_regex = /\A[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/

      return str if str =~ ipv4_regex || str =~ ipv6_regex

      if str =~ dns_regex
        ip = `dig +short #{str}`.strip
        return ip unless ip.empty?
      end
      nil
    end
  end
end
