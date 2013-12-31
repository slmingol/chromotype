class CreateAssetUrls < ActiveRecord::Migration
  def change
    create_table :asset_urls do |t|
      t.references :asset, :required => true
      t.string :url, :limit => 2000, :required => true
      # this is the sha of the URL itself, not the content at that URL:
      t.string :url_sha, :limit => 40, :required => true
      t.timestamps
    end

    add_foreign_key(:asset_urls, :assets)

    # MySQL can only have 760 chars in an index, so let's index the url by sha.
    add_index :asset_urls, [:url_sha], :name => 'asset_url_sha_udx', :unique => true
  end
end
