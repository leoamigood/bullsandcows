class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.string  :channel
      t.string  :language, default: 'RU'
      t.string  :complexity, default: 'easy'
      t.integer :dictionary_id

      t.timestamps null: false
    end
  end
end
