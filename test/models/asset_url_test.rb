require "test_helper"

describe AssetUrl do
  it "should normalize file URIs properly" do
    a = Asset.create!
    au = a.add_pathname("/a/b/c")
    au.reload.url.must_equal("file:///a/b/c")
  end

  it "should find by filename" do
    a = Asset.create!
    au1 = a.add_pathname("/a/b/c")
    au2 = a.add_pathname("/d/e/f")
    AssetUrl.with_filename("/a/b/c").to_a.must_equal([au1])
    AssetUrl.with_filename("/d/e/f").to_a.must_equal([au2])
    AssetUrl.with_any_filename(["/d/e/f", "/g/h/i"]).to_a.must_equal([au2])
    AssetUrl.with_any_filename(["/g/h/i"]).to_a.must_equal([])
    AssetUrl.with_any_filename(["/g/h/i", "/a/b/c"]).to_a.must_equal([au1])
    AssetUrl.with_any_filename(["/g/h/i", Pathname.new("/a/b/c"), "/d/e/f"]).to_a.must_equal([au1, au2])
  end
end
