class CreateGame < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string  :secret, limit: 64

      t.timestamps nill: false
    end
  end
end
