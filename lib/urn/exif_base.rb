module URN
  class ExifBase
    extend CacheSupport

    def self.urn_for_pathname(pathname)
      cached_with_short_ttl(pathname) do
        exif_result = ExifMixin.exif_result(pathname)
        if exif_result &&!exif_result.errors?
          a = urn_array_from_exif(exif_result)
          (urn_prefix + a.join('|')) if a
        end
      end
    end
  end
end
