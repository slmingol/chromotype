module URN
  class FsAttrs
    extend CacheSupport

    def self.urn_prefix
      'urn:fs-attrs:'
    end

    def self.urn_for_pathname(pathname)
      cached_with_short_ttl(pathname) do
        "#{urn_prefix}#{pathname.mtime.to_i}|#{pathname.size}"
      end
    end
  end
end
