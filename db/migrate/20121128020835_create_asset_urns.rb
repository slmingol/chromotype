class CreateAssetUrns < ActiveRecord::Migration
  def change
    create_table :asset_urns do |t|
      t.references :asset_url, :required => true
      t.string :urn, :limit => 200, :required => true
    end
    add_foreign_key(:asset_urns, :asset_urls)
    add_index(:asset_urns, [:asset_url_id, :urn], :name => 'asset_url_urn_udx', :unique => true)
    add_index(:asset_urns, [:urn], :name => 'asset_urn_idx') # Can't be unique, dupe files will have the same URNs.
  end
end
