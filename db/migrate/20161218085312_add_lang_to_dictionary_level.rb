class AddLangToDictionaryLevel < ActiveRecord::Migration
  def change
    add_column :dictionary_levels, :lang, :string
  end
end
