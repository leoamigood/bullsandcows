class ChangeGameStatusType < ActiveRecord::Migration[5.1]
  def change
    change_column :games, :status, :string
  end
end
