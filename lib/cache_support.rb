module CacheSupport
  def cached_with_short_ttl(key, &block)
    short_ttl_cache.fetch(cache_key(key)) { yield }
  end

  def cached_with_long_ttl(key, &block)
    long_ttl_cache.fetch(cache_key(key)) { yield }
  end

  def short_ttl_cache
    @short_ttl_cache ||= ActiveSupport::Cache::MemoryStore.new(
      :size => 32.megabytes,
      :max_prune_time => 5.minutes # <- long enough to prevent re-exiftool and URNing?
    )
  end

  def clear_cache!
    @short_ttl_cache.clear if @short_ttl_cache
    @long_ttl_cache.clear if @long_ttl_cache
  end

  def long_ttl_cache
    @long_ttl_cache ||= ActiveSupport::Cache::FileStore.new(
      Setting.cache_root,
      :max_prune_time => 1.month
    )
  end

  # Works whether include'd or extend'ed:
  def class_name
    self.class == Class ? self.name : self.class.name
  end

  def cache_key(key)
    "#{class_name}_#{key}"
  end
end
