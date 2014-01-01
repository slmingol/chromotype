require "test_helper"

describe "asset processing without image resizing" do
  before :each do
    ImageResizer.stubs(:visit_asset) # this takes a while, and we aren't testing it here, so skip.
    @ap = AssetProcessor.new
  end

  def process_img_2452
    p = img_path("IMG_2452.jpg")
    asset = @ap.perform(p)
    return asset, p.realpath
  end

  it "should work on insert" do
    asset, path = process_img_2452
    asset.asset_urls.collect { |ea| ea.url }.must_equal [path.to_uri.to_s]
  end

  it "should find the prior asset" do
    asset, path = process_img_2452
    pa = ProtoAsset.new(path)
    pa.asset.must_equal(asset)
    pa.asset_state.must_equal :old
  end

  it "should process DSLR assets with EXIF headers" do
    asset = @ap.perform(img_path("Canon 20D.jpg"))
    asset_must_include_all_tags(asset,
      "when/2004/9/19" => "DateTag",
      "when/seasons/autumn" => "SeasonTag",
      "with/Canon/EOS 20D" => "CameraTag",
      "file" + (Rails.root + "test/images").to_s => "DirTag"
    )
  end

  it "should process DroidX assets with EXIF headers" do
    asset = @ap.perform(img_path("Droid X.jpg"))
    asset_must_include_all_tags(asset,
      "when/2010/12/8" => "DateTag",
      "when/seasons/winter" => "SeasonTag",
      "with/Motorola/DROIDX" => "CameraTag",
      "file" + (Rails.root + "test/images").to_s => "DirTag"
    )
  end

  it "should process GPS-tagged asset" do
    asset = @ap.perform(img_path("iPhone 4S.jpg"))
    expected = {
      "when/2011/11/23" => "DateTag",
      "when/seasons/autumn" => "SeasonTag",
      "with/Apple/iPhone 4S" => "CameraTag",
      "file" + (Rails.root + "test/images").to_s => "DirTag",
      "where/Earth/North America/United States/California/San Mateo County/El Granada" => "GeoTag"
    }
    asset_must_include_all_tags(asset, expected)
  end

  it "should extract face tags from picasa" do
    asset = @ap.perform(img_path("faces.jpg"))
    asset_must_include_all_tags(asset,
      "when/2005/11/26" => "DateTag",
      "with/Canon/EOS 20D" => "CameraTag",
      "when/seasons/autumn" => "SeasonTag",
      "who/McEachen/James" => "FaceTag",
      "who/McEachen/Jamie" => "FaceTag",
      "who/McEachen/Karen" => "FaceTag",
      "who/McEachen/Matthew" => "FaceTag",
      "who/McEachen/Ruth" => "FaceTag",
      "file" + (Rails.root + "test/images").to_s => "DirTag"
    )
  end

  it "finds the same prior-imported assets" do
    img = img_path("iPhone 4S.jpg")
    with_tmp_dir do |dir|
      Setting.library_root = dir + "library"
      FileUtils.mkdir "imgs"
      FileUtils.cp img, img1 = "imgs/tmp1.jpg"
      FileUtils.cp img, img2 = "imgs/tmp2.jpg"
      a1 = @ap.perform(img1)
      urns = a1.asset_urns.collect { |ea| ea.urn }
      a2 = @ap.perform(img2)
      a1.must_equal(a2)
      a2.asset_urns.collect { |ea| ea.urn }.must_equal_contents urns

      FileUtils.cp img, img3 = "imgs/tmp3.jpg"
      pa = ProtoAsset.new(img3)
      pa.asset.must_equal(a1)
      pa.asset_state.must_equal :adopted
    end
  end

  it "combines original and edited assets" do
    img1 = img_path("IMG_2452.jpg")
    img2 = img_path("IMG_2452_picasa.jpg")
    with_tmp_dir do |dir|
      Setting.library_root = dir
      a1 = @ap.perform(img1)
      urns1 = a1.asset_urns.collect { |ea| ea.urn }
      a2 = @ap.perform(img2)
      a1.must_equal(a2)
      urns2 = a2.asset_urns.collect { |ea| ea.urn }

      # Only the EXIF urn should match:
      exif_urn1 = urns1.find { |ea| ea.starts_with? URN::Exif.urn_prefix }
      exif_urn2 = urns2.find { |ea| ea.starts_with? URN::Exif.urn_prefix }
      exif_urn1.must_equal exif_urn2
    end
  end

  it "doesn't adopt prior-imported assets with different URNs" do
    img1 = img_path("iPhone 4S.jpg")
    img2 = img_path("Droid X.jpg")
    with_tmp_dir do |dir|
      Setting.library_root = dir + "library"
      a1 = @ap.perform(img1)
      urns1 = a1.asset_urns.collect { |ea| ea.urn }
      a2 = @ap.perform(img2)
      a1.wont_equal(a2)
      urns2 = a2.asset_urns.collect { |ea| ea.urn }
      urns1.wont_include_any urns2
    end
  end
end

describe "asset processing with image resizing" do
  it "creates resized image assets" do
    with_tmp_dir do |dir|
      Setting.library_root = dir
      thumbnail_root = Setting.thumbnail_root.to_s
      # Make sure the thumbnail root is where we think it should be:
      thumbnail_root.must_match /^#{dir.to_s}/

      widths, heights = [], []
      Setting.resizes.each do |ea|
        w, h = ea.split("x").to_i
        widths << w
        heights << h
      end
      widths += Setting.square_crop_sizes
      heights += Setting.square_crop_sizes

      ap = AssetProcessor.new
      ap.perform(img_path("Canon 20D.jpg"))

      Dir["#{thumbnail_root}/**/*.jpg"].each do |f|
        w, h = Dimensions.dimensions(f)
        assert(widths.include?(w) || heights.include?(h),
          "neither dimension of #{w}x#{h} was expected for #{f}")
      end
    end
  end
end
