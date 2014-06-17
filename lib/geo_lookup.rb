require 'nominatim'
require 'geonames_api'

class GeoLookup
  include CacheSupport
  include AttrMemoizer

  def initialize(lat, lng)
    @lat = lat
    @lng = lng
  end

  # TODO: geo paths should be stored as tuples of geoname_id:place_name, so when GeoNames changes
  # names of places, it doesn't orphan the items with the old name

  def paths
    # No one has ever taken a photo at exactly 0, 0.
    return [] if [@lat.to_f, @lng.to_f] == [0, 0]
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

  attr_memoizer :place_path

  def place_path
    with_lat_lng("place") do |lat, lng|
      # Is there a POI that's < 250m away?
      place = GeoNamesAPI::Place.find(lat: lat, lng: lng, radius: 0.25)
      if place
        if osm_city_path
          osm_city_path + [place.name]
        else
          geo_to_path(place)
        end
      end
    end
  end

  def admin_name2
    gn_city_path[2] if gn_city_path
  end

  attr_memoizer :neighbourhood_path

  def neighbourhood_path
    with_lat_lng("hood") do |lat, lng|
      begin
        # .5km away
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

  attr_memoizer :gn_city_path

  def gn_city_path
    with_lat_lng("gn_city") do |lat, lng|
      # 2km away
      city = GeoNamesAPI::Place.find(lat: lat, lng: lng, cities: 'cities1000')
      geo_to_path(city)
    end
  end

  attr_memoizer :osm_city_path

  def osm_city_path
    with_lat_lng("osm_city") do |lat, lng|
      place = Nominatim.reverse(lat, lng).address_details(true).fetch
      a = place.try(:address)
      if a
        # Open Street Map doesn't like "County" suffixes, even when it's part of the name.
        county = if a.county
          county_with_suffix = a.county + " County"
          county_with_suffix == admin_name2 ? county_with_suffix : a.county
        end
        [a.country_code.upcase, a.state, county, a.city, a.town, a.village, a.suburb].compact_blanks if a
      end
    end
  end

  attr_memoizer :state_path

  def state_path
    with_lat_lng("state") do |lat, lng|
      state = GeoNamesAPI::CountrySubdivision.find(lat: lat, lng: lng, radius: 1)
      [state.country_code.upcase, state.admin_name1] if state
    end
  end

  # See http://en.wikipedia.org/wiki/Decimal_degrees#Accuracy
  # 4 digits gives us ~10m resolution, 3 digits gives us ~100m resolution.
  # Given that most aGPS have ~50m resolution, and we want some cache hits, we
  # default to 3.
  def with_lat_lng(method, ndigits = 3)
    lat = @lat.round(ndigits)
    lng = @lng.round(ndigits)
    cached_with_long_ttl("#{method}(#{lat},#{lng})") do
      yield(lat, lng)
    end
  end

  def geo_to_path(geo)
    return nil if geo.nil?
    [geo.country_code.upcase, geo.admin_name1, geo.admin_name2, geo.admin_name3, geo.admin_name4, geo.name]
  end
end
