class AddQbLocationIdToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :qb_location_id, :integer
  end
end
