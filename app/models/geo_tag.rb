require 'geonames_api'

class GeoTag < Tag
  extend CacheSupport # only used in class methods

  def self.root_name
    'where'
  end

  def self.visit_asset(exif_asset)
    # todo: short-circuit if we already have geo tags
    e = exif_asset.exif
    if tag = tag_for_lat_lon(e[:gps_latitude], e[:gps_longitude])
      exif_asset.add_tag(tag, self)
    end
  end

  def self.tag_for_lat_lon(lat, lng)
    return nil if lat.nil? || lng.nil?
    place_path = cached_with_long_ttl("%.6f:%.6f" % [lat, lng]) do
      if Setting.geonames_username
        GeoNamesAPI.username = Setting.geonames_username
      end
      places_nearby = GeoNamesAPI::Place.find(lat: lat, lng: lng) || []
      nearest = places_nearby.first
      return nil if nearest.nil? || nearest.geoname_id.to_i == 0
      places = GeoNamesAPI::Hierarchy.find(geonameId: nearest.geoname_id)
      places.collect { |ea| ea.name }
    end
    named_root.find_or_create_by_path(place_path)
  end
end
