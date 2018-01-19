class ExtendDictionarySourceLength < ActiveRecord::Migration[5.1]
  def change
    change_column :dictionaries, :source, :string, :limit => 255
  end
end
