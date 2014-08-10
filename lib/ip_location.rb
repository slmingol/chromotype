require 'nokogiri'
require 'open-uri'
require 'timeout'

class IpLocation
  # Yeah, I'm going to geek hell for the xpaths, but it's just to be nice to the user, so it's OK.
  def self.latitude_maxmind
    Timeout::timeout(5) do
      doc = Nokogiri::HTML(open('http://www.maxmind.com/app/locate_my_ip'))
      doc.xpath('//td[contains(text(), "Latitude")]/following-sibling::td').text.split("/").first.strip
    end
  end

  def self.latitude_geoiptool
    Timeout::timeout(5) do
      doc = Nokogiri::HTML(open('http://www.geoiptool.com/en/'))
      doc.xpath('//span[text()="Latitude:"]/../../td[2]').text
    end
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
    l = latitude
    l ? l.to_f > 0 : nil
  end
end
