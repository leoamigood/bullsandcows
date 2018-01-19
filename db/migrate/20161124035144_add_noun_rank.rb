class AddNounRank < ActiveRecord::Migration[5.1]
  def change
    add_column :nouns, :rank, :integer
  end
end
