# encoding: utf-8
require 'test_helper'

describe GeoLookup do
  describe '#paths' do
    it 'finds Disneyland' do
      GeoLookup.new(33.810974, -117.917485).paths.must_equal [
        ["US", "California", "Orange County", "Anaheim", "Anaheim Resort District", "Space Mountain"]
      ]
    end
    it 'finds Angel Island' do
      GeoLookup.new(37.867906, -122.434190).paths.must_equal [
        ["US", "California", "Marin County", "Tiburon", "Angel Island State Park Visitor Center"]
      ]
    end
    it 'finds Discovery Museum' do
      GeoLookup.new(37.835455, -122.476142).paths.must_equal [
        ["US", "California", "Marin County", "Discovery Museum"]
      ]
    end
    it 'finds Times Square' do
      GeoLookup.new(40.759129, -73.984872).paths.must_equal [
        ["US", "New York", "New York County", "New York City", "Upper East Side", "Palace Theater"]
      ]
    end
    it 'finds Liberty from Staten Island Ferry' do
      GeoLookup.new(40.680413, -74.035675).paths.must_equal [
        ["US", "New York", "New York County", "New York City"]
      ]
    end
    it 'finds Liberty from Liberty Island' do
      # According to http://en.wikipedia.org/wiki/Liberty_Island
      # Liberty Island is located in the Upper New York Bay surrounded by the waters of Jersey City, Hudson County, New Jersey
      # WHO KNEW?
      GeoLookup.new(40.689363, -74.044437).paths.must_equal [
        ["US", "New Jersey", "Hudson County", "Jersey City", "Statue of Liberty"]
      ]
    end
    it 'finds Santa Barbara Mission' do
      GeoLookup.new(34.438130, -119.713004).paths.must_equal [
        ["US", "California", "Santa Barbara County", "Santa Barbara", "Mission Santa Barbara"]
      ]
    end
    it 'finds Isla Vista' do
      # I would have also accepted Isla Vista.
      GeoLookup.new(34.411753, -119.859759).paths.must_equal [
        ["US", "California", "Santa Barbara County", "Santa Barbara", "Trigo-Pasado Park"]
      ]
    end
    it 'finds Academy of Sciences' do
      GeoLookup.new(37.770034, -122.466056).paths.must_equal [
        ["US", "California", "San Francisco City and County", "San Francisco", "California Academy of Sciences"]
      ]
    end
    it 'finds the Eiffel Tower' do
      GeoLookup.new(48.858761, 2.293763).paths.must_equal [
        ["FR", "Ile-de-France", "Paris", "Paris", "Gros-Caillou", "Eiffel Tower"]
      ]
    end
    it 'finds the Jaggar Volcano Museum' do
      GeoLookup.new(19.419719, -155.287874).paths.must_equal [
        ["US", "Hawaii", "Hawaiʻi County", "Volcano"]
      ]
    end
    it 'finds Landscape Arch' do
      GeoLookup.new(38.791129, -109.606131).paths.must_equal [
        ["US", "Utah", "Grand County", "Landscape Arch"]
      ]
    end
    it 'finds the Lincoln Memorial' do
      GeoLookup.new(38.889390, -77.049223).paths.must_equal [
        ["US", "District of Columbia", "Washington", "Southwest Waterfront", "Lincoln Memorial"]
      ]
    end
    it 'finds the Globe Theatre' do
      GeoLookup.new(51.508171, -0.097085).paths.must_equal [
        ["GB", "England", "Greater London", "Borough", "Shakespeares Globe"]
      ]
    end
    it 'finds the other Globe Theatre' do
      GeoLookup.new(42.196110, -122.715072).paths.must_equal [
        ["US", "Oregon", "Jackson County", "Ashland", "Oregon Shakespeare Festival"]
      ]
    end

  end

  describe ".uniq_paths" do
    it 'works' do
      input = [nil, [:a], [:a, :b], [:a, :b, :c], [:a, :b, :c, :d], [:e, :f, :g], [:f], [:e, :f]].shuffle
      GeoLookup.uniq_paths(input).must_equal_contents [[:a, :b, :c, :d], [:e, :f, :g], [:f]]
    end
  end
end
