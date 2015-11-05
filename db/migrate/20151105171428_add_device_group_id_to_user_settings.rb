class AddDeviceGroupIdToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :device_group_id, :integer
  end
end
