class AddActiveAndLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, :default => false
    add_column :users, :location, :string, :default => "Location"
  end
end
