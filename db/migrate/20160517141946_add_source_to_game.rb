class AddSourceToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :channel, :string, after: :secret
    add_column :games, :source, :string, after: :channel
  end
end
