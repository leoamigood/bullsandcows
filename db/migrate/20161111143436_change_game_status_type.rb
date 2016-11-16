class ChangeGameStatusType < ActiveRecord::Migration
  def change
    change_column :games, :status, :string
  end
end
