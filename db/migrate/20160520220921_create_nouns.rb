class CreateNouns < ActiveRecord::Migration
  def change
    create_table :nouns do |t|
      t.string  :noun, limit: 64
      t.string  :lang, limit: 2, default: :EN
    end
  end
end
