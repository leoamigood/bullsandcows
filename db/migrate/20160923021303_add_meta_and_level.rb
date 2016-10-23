class AddMetaAndLevel < ActiveRecord::Migration
  def change
    add_column :nouns, :excluded, :boolean, after: :noun, null: false, default: false
    add_column :nouns, :level, :integer, after: :dictionary_id
    add_column :nouns, :ipm, :float, after: :level
    add_column :nouns, :r, :integer, after: :ipm
    add_column :nouns, :d, :integer, after: :r
    add_column :nouns, :doc, :integer, after: :d

    add_column :games, :level, :integer, default: nil

    remove_column :nouns, :lang
  end
end
