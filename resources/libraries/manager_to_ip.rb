# frozen_string_literal: true

require 'resolv'

module RbIps
  module Helpers
    IPV4_REGEX = /\A(?:\d{1,3}\.){3}\d{1,3}\z/.freeze
    IPV6_REGEX = /\A(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}\z/.freeze
    DNS_REGEX  = /\A[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/.freeze

    # Resolves an IP string or domain name to an IP.
    # - Returns the same IP is the input is an IP
    # - Otherwise, resolves the IP if the input is a domain the first resolved IP for a domain
    # - Returns nil if the domain cannot be resolved
    def manager_to_ip(domain)
      return domain if domain.match?(IPV4_REGEX) || domain.match?(IPV6_REGEX)
      return Resolv.getaddress(domain).to_s if domain.match?(DNS_REGEX)

      nil
    end
  end
end
