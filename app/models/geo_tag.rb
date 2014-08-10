require 'geonames_api'

class GeoTag < Tag
  def self.root_name
    'where'
  end

  def self.for_lat_lng(lat, lng)
    geo = GeoLookup.new(lat, lng)
    if geo.place_id
      where(pk: geo.place_id).first || begin
        attrs = geo.path.map { |ea| {name: ea} }
        attrs.last[:pk] = geo.place_id
        named_root.find_or_create_by_path(attrs)
      end
    end
  end

  def self.visit_asset(exif_asset)
    # short-circuit if we already have lat and lng.
    return if exif_asset.lat || exif_asset.lng || NetworkStatus.down?
    e = exif_asset.exif
    lat = e[:gps_latitude]
    lng = e[:gps_longitude]
    if lat.to_f != 0 && lng.to_f != 0
      exif_asset.lat ||= lat
      exif_asset.lng ||= lng
      exif_asset.save
      geo_tag = for_lat_lng(lat, lng)
      exif_asset.add_tag(geo_tag, self) if geo_tag
    end
  end
end


