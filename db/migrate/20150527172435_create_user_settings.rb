class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.boolean :show_thumbnails, :default => false
      t.string :table_name, :default => "images"
      t.integer :user_id
      
      t.timestamps
    end
  end
end
