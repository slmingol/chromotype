require "minitest_helper"

describe Asset do
  before :each do
    @asset = Asset.new
    @path = "Gemfile".to_pathname.realpath
    @asset.uri = @path
    @asset.save!
    @uri = @path.to_uri.to_s
  end

  def assert_path
    @asset.uri.must_equal(@path.to_uri)
    @asset.should have(1).asset_uris
    au = @asset.asset_uris.first
    au.to_uri.must_equal(@path.to_uri)
    au.uri.must_equal(@path.to_uri.to_s)
  end

  it "should work on insert" do
    assert_path
  end

  it "should find with_filename(pathname)" do
    Asset.with_any_filename([@path]).to_a.must_equal([@asset])
  end

  it "should find with_uri(pathname)" do
    Asset.with_uri(@path.to_uri).to_a.must_equal([@asset])
  end

  it "should find with_filename(to_s)" do
    Asset.with_any_filename([@path.to_s]).to_a.must_equal([@asset])
  end

  it "should be a no-op on Asset.uri= with existing uri" do
    @asset.uri = Pathname.new("Gemfile")
    @asset.save!
    assert_path
    @asset.uri = @path
    @asset.save!
    assert_path
  end

  it "should add another #uri=" do
    u = "https://s3.amazonaws.com/test/test/Gemfile"
    @asset.uri = u
    @asset.save!
    @asset.reload.should have(2).asset_uris
    au = @asset.asset_uris.first
    au.uri.must_equal(u)
    @asset.asset_uris.second.uri.must_equal(@uri)
  end

  it "should fail to give the same URI to another asset" do
    a = Asset.create!
    lambda { a.uri = Pathname.new("Gemfile") }.should raise_error(ArgumentError)
  end
end
