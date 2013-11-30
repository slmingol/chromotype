module URN
  class Exif
    extend CacheSupport

    def self.urn_prefix
      'urn:exif:'
    end

    def self.urn_for_pathname(pathname)
      cached_with_short_ttl(pathname) {
        a = urn_array(pathname)
        (urn_prefix + a.join(';')) if a
      }
    end

    def self.urn_array(pathname)
      exif_result = ExifMixin.exif_result(pathname)
      if exif_result && !exif_result.errors? && exif_result.raw_hash[:create_date]
        # These fields seem to be durable even when edited:
        # Can't use :serial_number or :image_number because Preview.app deletes that tag.
        [
          exif_result.raw_hash[:create_date],
          exif_result[:f_number].to_s,
          exif_result[:iso].to_s,
          exif_result[:aperture].to_s,
          exif_result[:shutter_speed].to_s,
          exif_result[:make],
          exif_result[:model]
        ]
      end
    end
  end
end
