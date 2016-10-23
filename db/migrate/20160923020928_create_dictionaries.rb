class CreateDictionaries < ActiveRecord::Migration
  create_table :dictionaries do |t|
    t.string  :source, limit: 64
    t.string  :lang, limit: 2
    t.boolean :enabled, default: true

    t.timestamps nill: false
  end

  def change
    add_column :games, :dictionary_id, :integer
    add_column :nouns, :dictionary_id, :integer, after: :noun
  end

end
