class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string  :channel
      t.string  :language, default: 'RU'
      t.string  :complexity, default: 'easy'
      t.integer :dictionary_id

      t.timestamps nill: false
    end
  end
end
