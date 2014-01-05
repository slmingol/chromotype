class CreateAssetsTags < ActiveRecord::Migration
  def change
    create_table :asset_tags, :id => false do |t|
      t.references :asset, :required => true, index: true
      t.references :tag, :required => true, index: true
      t.string :visitor # <- the classname that added this tag
      t.timestamps
    end
    add_foreign_key(:asset_tags, :assets)
    add_foreign_key(:asset_tags, :tags)
  end
end
