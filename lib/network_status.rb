require 'net/http'

class NetworkStatus
  extend CacheSupport

  def self.up?
    cached_with_short_ttl(:up?) do
      %w[google.com icann.org mozilla.org twitter.com w3.org].shuffle.any? { |h| site_up?(h) }
    end
  end

  def self.site_up?(hostname)
    # We could use ping, but the local firewall might block outbound ICMP.
    Net::HTTP.start(hostname, :open_timeout => 2, :read_timeout => 1) do |http|
      http.head('/')
    end.present?
  rescue SocketError, Net::OpenTimeout
    false
  end
end
