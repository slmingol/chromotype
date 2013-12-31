require "test_helper"

describe Tag do

  # I don't know if/when I'd need this... :\
  #context :deletion do
  #  before :each do
  #    puts Asset.deleted.to_a
  #    Asset.not_deleted.to_a.should =~ @assets
  #  end
  #
  #  it "should deactivate direct assets" do
  #    @tag3.deactivate_assets
  #    Asset.deleted.to_a.must_equal([@assets[2]])
  #  end
  #  it "should deactivate indirect assets" do
  #    @tag1.deactivate_assets
  #    Asset.deleted.to_a.must_equal(@assets)
  #    Asset.not_deleted.to_a.should be_empty
  #  end
  #end
end
