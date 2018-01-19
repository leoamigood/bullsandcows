class CreateDictionaries < ActiveRecord::Migration[5.1]
  create_table :dictionaries do |t|
    t.string  :source, limit: 64
    t.string  :lang, limit: 2
    t.boolean :enabled, default: true

    t.timestamps null: false
  end

  def change
    add_column :games, :dictionary_id, :integer
    add_column :nouns, :dictionary_id, :integer, after: :noun
  end

end
