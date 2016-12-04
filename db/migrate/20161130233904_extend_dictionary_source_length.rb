class ExtendDictionarySourceLength < ActiveRecord::Migration
  def change
    change_column :dictionaries, :source, :string, :limit => 255
  end
end
