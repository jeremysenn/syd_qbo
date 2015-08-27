class AddActiveAndLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, :default => true
    add_column :users, :location, :string, :default => ""
  end
end
