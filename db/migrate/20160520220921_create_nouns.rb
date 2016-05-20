class CreateNouns < ActiveRecord::Migration
  def change
    create_table :nouns do |t|
      t.string  :noun, limit: 64
      t.string  :lang, limit: 2, default: :EN
    end

    Noun.reset_table_name

    File.readlines('tmp/seed_data/nouns.en.txt').each do |line|
      Noun.create(noun: line.chomp)
    end
  end
end
