class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :type
      t.boolean :favorite
      t.boolean :hidden
      t.string :basename
      t.string :caption
      t.string :description
      t.timestamp :taken_at
      t.datetime :lost_at
      t.float :lat
      t.float :lng
      t.integer :visited_by_version
      t.timestamps
    end

    # TODO: we may want an index to show not-lost assets, and not-lost, favorite assets
  end
end
