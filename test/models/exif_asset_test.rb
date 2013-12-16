require 'test_helper'

describe ExifAsset do

  before do
    @asset = ExifAsset.create_with_pathname(img_path('IMG_2452.jpg'))
  end

  it 'extracts captured_at properly' do
    @asset.captured_at.ymd.must_equal 20110706
  end
end

