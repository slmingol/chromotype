require 'nokogiri'
require 'open-uri'

class IpLocation
  extend CacheSupport

  # Yeah, I'm going to geek hell for the xpaths, but it's just to be nice to the user, so it's OK.
  def self.latitude_maxmind
    doc = Nokogiri::HTML(open('http://www.maxmind.com/app/locate_my_ip'))
    doc.xpath('//td[contains(text(), "Latitude")]/following-sibling::td').text.split("/").first.strip
  end

  def self.latitude_geoiptool
    doc = Nokogiri::HTML(open('http://www.geoiptool.com/en/'))
    doc.xpath('//span[text()="Latitude:"]/../../td[2]').text
  end

  def self.latitude
    latitude_maxmind
  rescue StandardError
    begin
      latitude_geoiptool
    rescue StandardError
      nil
    end
  end

  def self.northern_hemisphere?
    cached_with_long_ttl('is_northern_hemisphere') do
      l = latitude
      l ? l.to_f > 0 : nil
    end
  end
end
