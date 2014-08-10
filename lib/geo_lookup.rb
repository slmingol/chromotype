require 'nominatim'
require 'geonames_api'

class GeoLookup
  include CacheSupport
  attr_reader :lat, :lng

  # See http://en.wikipedia.org/wiki/Decimal_degrees#Accuracy
  # 4 digits gives us ~10m resolution, 3 digits gives us ~100m resolution.
  # Given that most aGPS have ~50m resolution, and we want some cache hits, we
  # default to 3.
  def initialize(lat, lng)
    @lat = lat.to_f.round(3)
    @lng = lng.to_f.round(3)
  end

  def path
    # longest wins
    paths.sort_by(&:size).last
  end

  def paths
    # No one has ever taken a photo at exactly 0, 0.
    return [] if [lat, lng] == [0, 0]
    paths = [place_path, osm_city_path].compact
    # Only use the state path if we're desperate:
    paths << state_path if paths.empty?
    self.class.uniq_paths(paths)
  end

  # uniq_paths(nil, [a,b,c], [a,b,c,d], [e,f,g]) = [a,b,c,d], [e,f,g]
  def self.uniq_paths(arrays)
    a = arrays.compact.uniq.map { |ea| ea.compact_blanks }
    a.select { |i| a.except(i).none? { |j| j.size > i.size && j.first(i.size) == i } }
  end

  def place
    with_cache(:place) do
      # Is there a POI that's <= 250m away?
      GeoNamesAPI::Place.find(lat: lat, lng: lng, radius: 0.25)
    end
  end

  def place_id
    place.try(:geoname_id)
  end

  def place_path
    if place
      osm_city_path_and_place(place.name) || geo_to_path
    end
  end

  def admin_name2
    gn_city_path[2] if gn_city_path
  end

  def neighbourhood_path
    with_cache(:neighbourhood) do
      begin
        # .25km away
        n = GeoNamesAPI::Neighbourhood.find(lat: lat, lng: lng, radius: 0.25)
        if n
          %w{countryCode adminName1 adminName2 city name}.map do |ea|
            n.neighbourhood[ea]
          end
        end
      rescue GeoNamesAPI::NoResultFound
        # no big whoop
      end
    end
  end

  def osm_city_path
    with_cache(:osm_city) do
      place = Nominatim.reverse(lat, lng).address_details(true).fetch
      a = place.try(:address)
      if a
        [a.country_code.upcase, a.state, a.county, a.city, a.town, a.village, a.suburb].compact_blanks
      end
    end
  end

  def osm_city_path_and_place(place_name)
    if osm_city_path
      if osm_city_path.last != place_name
        osm_city_path + [place_name]
      else
        osm_city_path
      end
    end
  end

  def state_path
    with_cache(:state_path) do
      state = GeoNamesAPI::CountrySubdivision.find(lat: lat, lng: lng, radius: 1)
      [state.country_code.upcase, state.admin_name1] if state
    end
  end

  def with_cache(method, &block)
    cached_with_long_ttl("#{method}_#{lat}_#{lng}", &block)
  end

  def geo_to_path(geo = place)
    return nil if geo.nil?
    [geo.country_code.upcase, geo.admin_name1, geo.admin_name2, geo.admin_name3, geo.admin_name4, geo.name]
  end
end
