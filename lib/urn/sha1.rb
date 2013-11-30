module URN
  class Sha1
    extend CacheSupport

    def self.urn_prefix
      'urn:sha1:'
    end

    def self.urn_for_pathname(pathname)
      cached_with_short_ttl(pathname) {
        urn_prefix + pathname.sha1
      }
    end
  end
end
