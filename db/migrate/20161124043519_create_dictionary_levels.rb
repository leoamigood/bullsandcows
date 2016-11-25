class CreateDictionaryLevels < ActiveRecord::Migration
  def change
    create_table :dictionary_levels do |t|
      t.integer :dictionary_id
      t.string  :complexity
      t.integer :min_level
      t.integer :max_level
    end
  end
end
