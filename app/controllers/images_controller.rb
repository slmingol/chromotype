class ImagesController < ApplicationController

  def index
  end

  def random
    send_file get_random_asset_path
  end

  private

  def get_random_asset_path
    Asset.order('RANDOM()').includes(:asset_urls).first.asset_urls[0].url.sub('file:/','')
  end

end
