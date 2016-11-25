class AddNounRank < ActiveRecord::Migration
  def change
    add_column :nouns, :rank, :integer
  end
end
