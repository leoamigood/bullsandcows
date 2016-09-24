class CreateDictionary < ActiveRecord::Migration
  create_table :dictionary do |t|
    t.string  :source, limit: 64
    t.string  :lang, limit: 2

    t.timestamps nill: false
  end
end
