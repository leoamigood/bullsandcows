class AddSourceToGame < ActiveRecord::Migration
  def change
    add_column :games, :channel, :string, after: :secret
    add_column :games, :source, :string, after: :channel
  end
end
