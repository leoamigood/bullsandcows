class AddMetaLevelToNouns < ActiveRecord::Migration
  def change
    remove_column :nouns, :lang

    add_column :nouns, :dictionary_id, :integer, after: :noun
    add_column :nouns, :level, :integer, after: :dictionary_id
    add_column :nouns, :ipm, :float, after: :level
    add_column :nouns, :r, :integer, after: :ipm
    add_column :nouns, :d, :integer, after: :r
    add_column :nouns, :doc, :integer, after: :d
  end
end
