class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :ext_id, null: false
      t.string :source, null: false
      t.string :first_name
      t.string :last_name
      t.string :username

      t.timestamps null: false
    end
  end
end
