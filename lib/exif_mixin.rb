# Assumes the mixin consumer has a "pathname" method
module ExifMixin
  extend CacheSupport

  def self.cache
    Chromotype::SHORT_TTL_CACHE
  end

  # Returns hash of filename => Exiftool::Results for
  # all the files that have valid EXIF headers. Results
  # may be from cache.
  def self.exif_results(*filenames)
    results = {}
    filenames = filenames.collect { |ea| ea.to_s }
    filenames.each { |ea| results[ea] = cache.read(cache_key(ea)) }
    results.delete_if { |k, v| v.nil? || v.errors? }
    missing = filenames - results.keys
    e = Exiftool.new(missing)
    unless e.errors?
      missing.each do |ea|
        result = e.result_for(ea)
        cache.write(cache_key(ea), result)
        results[ea] = result
      end
    end
    results
  end

  def self.exif_result(filename)
    f = filename.to_s
    cache.fetch(cache_key(f)) do
      e = Exiftool.new(f)
      e.result_for(f) unless e.errors?
    end
  end

  def exif_result
    ExifMixin.exif_result(self.pathname)
  end

  def exif?
    !exif_result.nil?
  end

  def exif
    exif_result.try(:to_hash)
  end

  def exif_display
    exif_result.try(:to_display_hash)
  end

  def image_pixels
    e = exif_result
    (e[:image_width].to_i * e[:image_height].to_i) unless e.nil?
  end

end
