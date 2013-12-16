module URN
  class ExifSerial < ExifBase

    def self.urn_prefix
      'urn:exif_serial:'
    end

    def self.urn_array_from_exif(exif_result)
      # Not all image software maintains these headers, so this URNer should be considered
      # auxiliary to URN::Exif.
      image_uid = [
        exif_result[:image_unique_id],
        exif_result[:shutter_count],
        exif_result[:image_number],
        exif_result[:file_number]
      ].compact_blanks.first
      # If we don't have an image_uid, we give up.
      if image_uid
        [
          image_uid,
          exif_result[:internal_serial_number],
          exif_result[:serial_number],
          # make and model are needed to make the serial number unique:
          exif_result[:make],
          exif_result[:model]
        ].for_each(:strip).compact_blanks
      end
    end
  end
end
