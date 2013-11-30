module URN
  class ExifSerial < Exif

    def self.urn_prefix
      'urn:exif_serial:'
    end

    def self.urn_array(pathname)
      exif_result = ExifMixin.exif_result(pathname)
      unless exif_result.present? && !exif_result.errors?
        file_uid = [exif_result[:image_unique_id], exif_result[:file_number]].compact
        if file_uid.present?
          cam_id = [exif_result[:serial_number], exif_result[:internal_serial_number]].compact
          cam_id = [exif_result[:make], exif_result[:model]] if cam_id.empty?
          file_uid + cam_id
        end
      end
    end
  end
end
