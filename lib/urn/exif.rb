module URN
  class Exif < ExifBase
    def self.urn_prefix
      'urn:exif:'
    end

    def self.urn_array_from_exif(exif_result)
      if exif_result.raw_hash[:create_date]
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
