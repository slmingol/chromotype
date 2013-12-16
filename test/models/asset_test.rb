require 'test_helper'

describe Asset do
  before :each do
    @asset = Asset.create!
    @path = 'Gemfile'.to_pathname.realpath
    @asset.add_pathname @path
    @url = @path.to_uri.to_s
  end

  def assert_path
    @asset.asset_urls.collect { |ea| ea.url }.must_equal [@url]
    au = @asset.asset_urls.first
    au.to_uri.must_equal(@path.to_uri)
    au.url.must_equal(@path.to_uri.to_s)
  end

  it 'inserts' do
    assert_path
  end

  it 'sets basename properly' do
    @asset.reload.basename.must_equal('Gemfile')
  end

  it 'finds with_filename' do
    Asset.with_filename(@path).to_a.must_equal([@asset])
  end

  it 'finds with_any_filename' do
    Asset.with_any_filename([@path]).to_a.must_equal([@asset])
  end

  it 'finds with_url' do
    with_url = Asset.with_url(@path.to_uri).to_a
    with_url.must_equal([@asset])
  end

  it 'finds with_any_url' do
    Asset.with_any_url([@path.to_uri]).to_a.must_equal([@asset])
  end

  it 'no-ops on Asset.add_pathname for existing paths' do
    @asset.add_pathname @path
    assert_path
  end

  it 'adds another #uri=' do
    u = "https://s3.amazonaws.com/test/test/Gemfile"
    @asset.add_url(u)
    @asset.reload.asset_urls.collect { |ea| ea.url }.must_equal [u, @url]
    au = @asset.asset_urls.first
    au.url.must_equal(u)
    @asset.asset_urls.second.url.must_equal(@url)
  end

  it 'fails to give the same URI to another asset' do
    a = Asset.create!
    new_pathname = a.add_pathname Pathname.new("Gemfile")
    new_pathname.must_be_nil
  end
end

