class AddUserIdToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :user_id, :integer
  end
end
