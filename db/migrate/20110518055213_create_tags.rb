class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :type
      t.integer :parent_id
      t.string :name, :required => true
      t.string :description
      t.timestamps
    end

    add_foreign_key(:tags, :tags, column: 'parent_id')

    add_index :tags, [:name, :parent_id], :unique => true

    create_table :tag_hierarchies, :id => false do |t|
      t.integer :ancestor_id, :required => true
      t.integer :descendant_id, :required => true
      t.integer :generations, :required => true
    end

    add_foreign_key(:tag_hierarchies, :tags, column: 'ancestor_id')
    add_foreign_key(:tag_hierarchies, :tags, column: 'descendant_id')

    # For "all progeny of..." selects:
    add_index :tag_hierarchies, [:ancestor_id, :descendant_id], :unique => true

    # For "all ancestors of..." selects
    add_index :tag_hierarchies, [:descendant_id]
  end
end
