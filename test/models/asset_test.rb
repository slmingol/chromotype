require 'test_helper'

describe Asset do
  before do
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

  describe 'tags' do
    before do
      @assets = 3.times.collect { Asset.create! }
      @tag0 = Tag.create!(name: 'test')
      @tag3 = Tag.find_or_create_by_path %w{parent child grandchild}
      @tag2 = @tag3.parent
      @tag1 = @tag2.parent
      @assets.first.add_tag(@tag1)
      @assets.second.add_tag(@tag2)
      @assets.third.add_tag(@tag3)
    end

    it 'finds assets by tag' do
      Asset.with_tag(@tag1).must_equal [@assets.first]
      Asset.with_tag(@tag2).must_equal [@assets.second]
      Asset.with_tag(@tag3).must_equal [@assets.third]
    end

    it 'finds descendant associations' do
      Asset.with_tag_or_descendants(@tag1).must_equal(@assets)
      Asset.with_tag_or_descendants(@tag2).must_equal(@assets.last(2))
      Asset.with_tag_or_descendants(@tag3).must_equal(@assets.last(1))
    end
  end
end

