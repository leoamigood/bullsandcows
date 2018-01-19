class AddLangToDictionaryLevel < ActiveRecord::Migration[5.1]
  def change
    add_column :dictionary_levels, :lang, :string
  end
end
