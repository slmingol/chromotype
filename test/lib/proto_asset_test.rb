require 'test_helper'

describe ProtoAsset do
  before :each do
    @pa = ProtoAsset.new(img_path('IMG_2452.jpg'))
  end

  it '#urns works' do
    @pa.urns.must_equal_hash(
      URN::FsAttrs => 'urn:fs-attrs:1329984295:2940995',
      URN::Sha1 => 'urn:sha1:026f5bac679f5373cd8503ca43586314d851eebb',
      URN::Exif => 'urn:exif:1309970805:2.8:160:2.8:1/800:Canon:Canon PowerShot SD980 IS'
    )
  end
end
