class CreateAssetsTags < ActiveRecord::Migration
  def change
    create_table :asset_tags, :id => false do |t|
      t.references :asset, :required => true, index: true
      t.references :tag, :required => true, index: true
      t.string :visitor # <- the classname that added this tag
      t.timestamps
    end
    add_index :asset_tags, [:tag_id, :asset_id], unique: true
  end
end
