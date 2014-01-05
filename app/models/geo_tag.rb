require 'geonames_api'

class GeoTag < Tag
  def self.root_name
    'where'
  end

  def self.visit_asset(exif_asset)
    # todo: short-circuit if we already have geo tags
    e = exif_asset.exif
    lat = e[:gps_latitude]
    lng = e[:gps_longitude]
    if lat.to_f != 0 && lng.to_f != 0
      exif_asset.lat ||= lat
      exif_asset.lng ||= lng
      exif_asset.save
    end
    GeoLookup.new(lat, lng).paths.each do |ea|
      tag = named_root.find_or_create_by_path(ea)
      exif_asset.add_tag(tag, self)
    end
  end
end


