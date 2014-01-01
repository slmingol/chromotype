module CacheSupport
  def cached_with_short_ttl(key, &block)
    Chromotype::SHORT_TTL_CACHE.fetch(cache_key(key)) { yield }
  end

  def cached_with_long_ttl(key, &block)
    Chromotype::LONG_TTL_CACHE.fetch(cache_key(key)) { yield }
  end

  # Works whether include'd or extend'ed:
  def class_name
   self.class == Class ? self.name : self.class.name
  end

  def cache_key(key)
    "#{class_name}-#{key}"
  end
end
