require 'geonames_api'

class GeoTag < Tag
  extend CacheSupport # only used in class methods

  def self.root_name
    'where'
  end

  def self.visit_asset(exif_asset)
    # todo: short-circuit if we already have geo tags
    e = exif_asset.exif
    lat = e[:gps_latitude]
    lng = e[:gps_longitude]
    tag = tag_for_lat_lon(lat, lng)
    exif_asset.add_tag(tag, self) if tag
  end

  def self.tag_for_lat_lon(lat, lng)
    return nil if [lat.to_f, lng.to_f] == [0, 0]
    # thousandths gives ~10m resolution.
    # See http://en.wikipedia.org/wiki/Decimal_degrees#Accuracy
    lat, lng = [lat, lng].map { |ea| ea.round(4) }
    place_path = cached_with_long_ttl("place(#{lat}, #{lng})") do
      # Is there a POI that's < 300 ft away?
      nearest_geo = GeoNamesAPI::Place.find(lat: lat, lng: lng, radius: 0.1)
      geoname_to_path(nearest_geo) ||
        neighbourhood_path_for_lat_lon(lat, lng) ||
        admin_path_for_lat_lon(lat, lng)
    end
    named_root.find_or_create_by_path(place_path) if place_path
  end

  def self.geoname_to_path(geoname)
    geoname_id = geoname.try(:geoname_id)
    if geoname_id
      cached_with_long_ttl("geo_path(#{geoname_id})") do
        places = GeoNamesAPI::Hierarchy.find(geonameId: geoname_id)
        places.map(&:name)
      end
    end
  end

  def self.neighbourhood_path_for_lat_lon(lat, lng)
    lat, lng = [lat, lng].map { |ea| ea.round(4) }
    cached_with_long_ttl("neighbourhood(#{lat},#{lng})") do
      begin
        GeoNamesAPI::Neighbourhood.find(lat: lat, lng: lng).try(:hierarchy)
      rescue GeoNamesAPI::Error
      end
    end
  end

  def self.admin_path_for_lat_lon(lat, lng)
    lat, lng = [lat, lng].map { |ea| ea.round(3) }
    cached_with_long_ttl("peopled_place(#{lat}, #{lng})") do
      result = GeoNamesAPI::Place.where(lat: lat, lng: lng, radius: 10)
      nearest_geo = result.to_a.sort_by do |ea|
        ea.distance
      end.detect do |ea|
        fcode = ea.fcode.to_s
        # http://www.geonames.org/export/codes.html
        fcode.starts_with?('ADM') || fcode.starts_with?('PPL')
      end
      geoname_to_path(nearest_geo)
    end
  end
end


