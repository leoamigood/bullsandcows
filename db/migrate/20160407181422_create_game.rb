class CreateGame < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string  :secret, limit: 64
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
