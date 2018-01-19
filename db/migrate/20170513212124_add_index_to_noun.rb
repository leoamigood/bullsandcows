class AddIndexToNoun < ActiveRecord::Migration[5.1]
  def change
    add_index :nouns, [:noun, :dictionary_id], unique: true
  end
end
